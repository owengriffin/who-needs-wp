# -*- coding: undecided -*-
require 'rubygems'
require 'rdiscount'
require 'haml'


require 'open-uri'
require 'sass'
require 'makers-mark'
require 'logger'
require 'rss/maker'
require 'net/ssh'
require 'net/sftp'
require 'who-needs-wp/css.rb'
require 'who-needs-wp/Sidebar.rb'
require 'who-needs-wp/sidebar/twitter.rb'
require 'who-needs-wp/sidebar/delicious.rb'
require 'who-needs-wp/sidebar/recentposts.rb'
require 'who-needs-wp/sidebar/pageindex.rb'
require 'who-needs-wp/templates.rb'
require 'who-needs-wp/posts.rb'
require 'who-needs-wp/pages.rb'

module WhoNeedsWP
  # A list of HTML strings which will be the sidebar
  @sidebar = []

  # Map of templates which are used to render content
  @template = []

  # Logger
  @logger = Logger.new(STDOUT)

  # Generate the site with the specified options
  def self.generate(options)
    @options = options
    if @options[:url] == '/'
      @options[:url] = ''
    end
    self.load_templates
    self.load_posts
    self.load_pages
    if @posts.length > 0
      RecentPosts.new
    end 
    if @pages.length > 0
      PageIndex.new
    end
    if @options[:twitter]
      if @options[:twitter][:username]
        TwitterFeed.new(@options[:twitter][:username])
      end 
      if @options[:twitter][:search]
        TwitterSearch.new(@options[:twitter][:search])
      end
    end
    if @options[:delicious]
      delicious = Delicious.new(@options[:delicious][:user])
    end 
    self.generate_posts
    self.generate_pages
    self.index
    self.all_posts
    self.css
    self.rss("posts.rss")
    self.atom("posts.atom")
    if @options[:upload] 
      self.upload
    end
  end

  # Generate the index page for the blog
  def self.index
    contents = ""
    if @posts.length > 0
      @posts[0..3].each do |post|
        contents << post[:html]
      end
    else
      contents << @pages.first[:html]
    end
    self.render_html("index.html", "index", contents)
  end

  # Generate a page containing a list of all posts
  def self.all_posts
    self.render_html("posts/all.html", "post_index", @template['all_posts'].render(Object.new, { 
                                                                              :posts => @posts, 
                                                                              :options => @options
                                                                            }), "All Posts")
  end

  def self.upload
    match = @options[:remote_addr].match(/(.*)@(.*):(.*)/)
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
