module WhoNeedsWP
  class Post < Content
    # Date at which content was created, or specified in filing structure
    attr_accessor :created_at
    # Create a new Post object
    def initialize(filename, created_at)
      super(filename)
      @created_at = created_at
    end

    # A list of all the pages on the site
    @@posts = []

    # Load all pages
    def self.load
      Dir.glob('posts/**/*.markdown').each do |filename|
        match = filename.match(/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/([^\.]*)/)
        date = DateTime.new(match[1].to_i, match[2].to_i, match[3].to_i)
        @@posts << Post.new(filename, date)
      end
      # Sort the posts
      @@posts.sort! { |a, b| a.created_at <=> b.created_at }
      @@posts.reverse!
    end

    # See Content.render_content
    def render(previous_post, next_post)
      @html = WhoNeedsWP::render_template("post", {
        :post => self,
        :title => @title,
        :previous_post => previous_post,
        :next_post => next_post
      })
      super()
    end

    # Render all the posts loaded
    def self.render_all
      @@posts.each_index do |index|
        post = @@posts[index]
        previous_post = @@posts[index + 1] if index + 1 < @@posts.length
        next_post = @@posts[index - 1] if index > 1
        post.render(previous_post, next_post)
      end
    end

    # Return all the posts created
    def self.all
      return @@posts
    end

    def self.index(filename = "posts/index.html")
      if File.exists?(File.dirname(filename))
        WhoNeedsWP::render_html(filename, "post_index", WhoNeedsWP::render_template("all_posts", {
          :posts => @@posts
        }), "All Posts")
      end
    end

    # Generate an RSS feed of all the posts
    def self.rss(filename = "posts.rss")
      File.open(filename, "w") do |file|
        file.write WhoNeedsWP::render_template("rss", {
          :posts => @@posts
        })
      end
    end

    # Generate an ATOM feed of all the posts
    def self.atom(filename = "posts.atom")
      File.open(filename, "w") do |file|
        file.write WhoNeedsWP::render_template("atom", {
          :posts => @@posts
        })
      end
    end
  end
end
