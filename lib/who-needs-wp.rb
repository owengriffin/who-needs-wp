require 'rubygems'
require 'rdiscount'
require 'haml'
require 'twitter'
require 'nokogiri'
require 'open-uri'
require 'sass'
require 'makers-mark'
require 'logger'

require 'who-needs-wp/css.rb'
require 'who-needs-wp/twitter.rb'
require 'who-needs-wp/delicious.rb'
require 'who-needs-wp/templates.rb'
require 'who-needs-wp/posts.rb'

module WhoNeedsWP
  # A list of HTML strings which will be the sidebar
  @sidebar = []

  # Map of templates which are used to render content
  @template = []

  # Logger
  @logger = Logger.new(STDOUT)

  def self.generate(options)
    @options = options
    self.load_templates
    self.load_posts
    self.twitter
    self.delicious
    self.recentposts
    self.generate_posts
    self.index
    self.css
  end
  def self.index
    File.open("index.html", "w") do |file|
      contents = ""
      @POSTS[0..3].each do |post|
        contents << post[:html]
      end
      file.puts @template['layout'].render(Object.new, {
                                            :content => contents, 
                                            :options => @options, 
                                            :sidebar => @sidebar.join
                                          })
    end
  end
end
