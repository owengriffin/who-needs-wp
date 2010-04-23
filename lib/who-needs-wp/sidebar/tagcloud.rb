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
      generate
      @logger.debug @tags
      WhoNeedsWP::render_template("tagcloud", { :tags => @tags })
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
        @tags << found
      end
      found[:count] = found[:count] + 1
    end

    def allocate_sizes
      min = 0
      max = 0
      @tags.each do |tag|
        min = tag[:count] if tag[:count] < min
        max = tag[:count] if tag[:count] > max
      end
      distribution = (max - min) / 3
      @tags.each do |tag|
        if tag[:count] == min
          tag[:size] = 'not-very-popular'
        elsif tag[:count] == max
          tag[:size] = 'ultra-popular'
        elsif tag[:count] > (min + (distribution * 2))
          tag[:size] = 'popular'
        elsif tag[:count] > (min + distribution)
          tag[:size] = 'somewhat-popular'
        else
          tag[:size] = 'not-popular'
        end
      end
    end

    def generate
      Post.all.each do |post|
        post.tags.each do |tag|
          create_and_increment(tag)
        end
      end
      # Ensure that the most frequent tags occur first
      @tags.sort! { |tag0, tag1|
        tag1[:count] <=> tag0[:count]
      }
      allocate_sizes
    end
  end
end
