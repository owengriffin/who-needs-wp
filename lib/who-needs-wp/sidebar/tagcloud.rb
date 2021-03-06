module WhoNeedsWP
  # A sidebar component to display a cloud of tags
  class TagCloud < Sidebar

    # Create a new tag cloud sidebar
    def initialize
      super()
      @tags = []
      @generated = false
    end

    # See Sidebar.render
    def render
      generate
      WhoNeedsWP::render_template("tagcloud", { :tags => @tags })
    end

    def generate_pages
      generate
      FileUtils.mkdir_p "tags" if not File.directory? "tags"
      @tags.each do |tag|
        @logger.info "Rendering page for #{tag[:name]}"
        contents = WhoNeedsWP::render_template("tag", { :tag => tag })
        title = "Posts which are tagged '#{tag[:name]}'"
        WhoNeedsWP.render_html("tags/#{tag[:name]}.html", "tag", contents, title, '', title)
      end
    end

    private

    def create_and_increment(name, post)
      found = nil
      @tags.each do |tag|
        if tag[:name] == name
          found = tag
          break
        end
      end
      if found == nil
        found = {:name => name, :count => 0, :posts => []}
        @tags << found
      end
      if not found[:posts].include? post
        found[:posts] << post
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
      if not @generated
        Post.all.each do |post|
          post.tags.each do |tag|
            create_and_increment(tag, post)
          end
        end
        # Ensure that the most frequent tags occur first
        @tags.sort! { |tag0, tag1|
          tag1[:count] <=> tag0[:count]
        }
        allocate_sizes
        @generated = true
      end
    end
  end
end
