module WhoNeedsWP
  # A sidebar component to display a cloud of tags
  class TagCloud < Sidebar
    # Create a new tag cloud sidebar
    def initialize
      super()
      @tags = []
    end

    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("tagcloud", { :tags => tags })
    end

    private

    def create_and_increment(name)
      found = nil
      @tags.each do |tag|
        if tag[:name] == name
          found = tag
          break
        end
      end
      if found == nil
        found = {:name => name, :count => 0}
      end
      found[:count] = found[:count] + 1
    end

    def generate
      Post.all.each do |post|
        post.tags.each do |tag|
          create_and_increment(tag)
        end
      end
      # Ensure that the most frequent tags occur first
      @tags.sort! { |tag0, tag1|
        tag0[:count] <=> tag1[:count]
      }
    end
  end
end
