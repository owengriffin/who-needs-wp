require 'rubygems'
require 'rdiscount'
require 'haml'
require 'twitter'
require 'nokogiri'
require 'open-uri'
require 'sass'
require 'makers-mark'
require 'logger'
require 'rss/maker'
require 'who-needs-wp/css.rb'
require 'who-needs-wp/twitter.rb'
require 'who-needs-wp/delicious.rb'
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
    self.load_templates
    self.load_posts
    self.load_pages
    self.recentposts
    self.page_index
 #   self.twitter
 #   self.delicious
    self.generate_posts
    self.generate_pages
    self.index
    self.all_posts
    self.css
    self.rss("posts.rss")
    self.atom("posts.atom")
  end

  # Generate the index page for the blog
  def self.index
    contents = ""
    if @POSTS.length > 0
      @POSTS[0..3].each do |post|
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
                                                                              :posts => @POSTS, 
                                                                              :options => @options
                                                                            }), "All Posts")
  end
end
