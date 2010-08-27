module WhoNeedsWP
  class Page < Content
    # A list of all the pages on the site
    @@pages = []
    # Load all pages
    def self.load
      Dir.glob('pages/*.{markdown,md}').each do |filename|
        @@pages << Page.new(filename)
      end
      @@pages.sort! { |a, b| a.title <=> b.title }
    end

    # See Content.render_content
    def render
      @html = WhoNeedsWP::render_template("page", {
        :page => self,
        :title => @title
      })
      super()
    end

    # Render all the pages loaded
    def self.render_all
      @@pages.each do |page|
        page.render
      end
    end

    # Return all the pages created
    def self.all
      return @@pages
    end
  end
end
