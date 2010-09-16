# -*- coding: utf-8 -*-
require 'rubygems'
require 'haml'
require 'open-uri'
require 'sass'
require 'kramdown'
require 'logger'
require 'rss/maker'
require 'net/ssh'
require 'net/sftp'
require 'rexml/document'
require 'net/http'

require 'who-needs-wp/css.rb'
require 'who-needs-wp/keywords.rb'
require 'who-needs-wp/sitemap.rb'
require 'who-needs-wp/Content.rb'
require 'who-needs-wp/content/Page.rb'
require 'who-needs-wp/content/Post.rb'
require 'who-needs-wp/Sidebar.rb'
require 'who-needs-wp/sidebar/twitter.rb'
require 'who-needs-wp/sidebar/delicious.rb'
require 'who-needs-wp/sidebar/recentposts.rb'
require 'who-needs-wp/sidebar/pageindex.rb'
require 'who-needs-wp/sidebar/latitude.rb'
require 'who-needs-wp/sidebar/tagcloud.rb'
require 'who-needs-wp/templates.rb'

module WhoNeedsWP

  # Map of templates which are used to render content
  @template = []

  # Logger
  @logger = Logger.new(STDOUT)

  def self.new_post(title)
    safe_title = title.gsub(/ /, '_')
    now = Time.new
    dir = "posts/#{now.strftime('%Y/%m/%d')}"
    filename = "#{dir}/#{safe_title}.markdown"
    
    count = 0
    splits = dir.split('/')
    splits.each do |d| 
      path = splits[0..count].join('/')
      if not File.exists? path
        @logger.debug "Creating: #{path}"
        Dir.mkdir path 
      end
      count = count + 1
    end

    File.new(filename, "w")
    @logger.info("Created file #{filename}")
  end

  # Generate the site with the specified options
  def self.generate(options)
    @options = options
    if @options[:url] == '/'
      @options[:url] = ''
    end

    online = true
    begin
      Socket.getaddrinfo('owengriffin.com', 'http')
    rescue SocketError
      @logger.warn "System is offline. Some resources may be skipped"
      online = false
    end

    self.load_templates
    #self.load_posts

    if @options[:twitter] and online
      if @options[:twitter][:username]
        TwitterFeed.new(@options[:twitter][:username])
      end
      if @options[:twitter][:search]
        TwitterSearch.new(@options[:twitter][:search])
      end
    end
    if @options[:delicious] and online
      delicious = Delicious.new(@options[:delicious][:user])
    end
    if @options[:latitude] and online
      Latitude.new(@options[:latitude])
    end
    Page.load
    Post.load
    if Post.all.length > 0
      RecentPosts.new
    end
    if Page.all.length > 0
      PageIndex.new
    end
    if @options[:tag_cloud]
      cloud = TagCloud.new
    end
    Page.render_all
    Post.render_all
    Post.atom
    Post.rss
    Post.index
    if cloud != nil or @options[:tag_cloud]
      @logger.info "Generating tag cloud"
      cloud.generate_pages
    end
    self.index
    self.css
    self.sitemap

    if @options[:upload]
      self.upload
    end
  end

  def self.options
    @options
  end

  # Generate the index page for the blog
  def self.index
    keywords = []
    contents = ""
    if Post.all.length > 0
      Post.all[0..3].each do |post|
        contents << post.html
        keywords = keywords + post.tags
      end
    else
      index_page = Page.all.first
      if @options[:index_page]
        Page.all.each do |page|
          if page.filename[:original] == @options[:index_page]
            index_page = page
            break
          end
        end
      end
      contents = index_page.html
    end
    self.render_html("index.html", "index", contents, "", keywords, @options[:index_summary])
  end

  def self.upload
    match = @options[:upload_url].match(/(.*)@(.*):(.*)/)
    username = match[1]
    host = match[2]
    remote_path = match[3]
    # Replace the tilda with the full path for home
    remote_path = "/home/#{username}/" + remote_path[1..remote_path.length] if remote_path =~ /^~.*$/
    local_path = Dir.pwd
    permissions = {
      :directory => 0755,
      :file => 0644
    }
    Net::SFTP.start(host, username) do |sftp|
      Dir.glob("**/*") do |filename|
        basename = File.basename(filename)
        if basename =~ /^\..*$/ or
        basename =~ /.*\.markdown$/ or
        basename =~ /^.*~$/ or
        basename =~ /^\#.*\#$/
          @logger.debug "Skipping #{filename}"
        else
          remote_filename = remote_path + filename.sub(local_path, '')
          @logger.debug "Remote filename = #{remote_filename}"

          # If the directory does not exist then create it
          begin
            if File.directory? filename
              remote_directory = remote_filename
            else
              remote_directory = File.dirname(remote_filename)
            end
            sftp.stat!(remote_directory)
          rescue Net::SFTP::StatusException
            @logger.debug "#{remote_directory} does not exist"
            sftp.mkdir!(remote_directory, :permissions => permissions[:directory])
          end

          if not File.directory? filename
            # If the file does not exist then create it
            begin
              status = sftp.stat!(remote_filename)
            rescue Net::SFTP::StatusException
              @logger.debug "#{remote_filename} does not exist"
              sftp.upload!(filename, remote_filename)
              sftp.setstat(remote_filename, :permissions => permissions[:file])
              next
            end

            # If the local file has changed then upload it
            if File.stat(filename).mtime > Time.at(status.mtime)
              @logger.debug "Copying #{filename} to #{remote_filename}"
              sftp.upload!(filename, remote_filename)
            else
              @logger.debug "Skipping #{filename}"
            end
          end
        end
      end
      @logger.debug "Disconnecting from remote server"
    end
  end
end
