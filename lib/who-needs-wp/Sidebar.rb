module WhoNeedsWP
  # Abstract class to be implemented by all sidebar elements
  class Sidebar
    # A list of Sidebar instances which will be rendered
    @@content = []

    # The HTML output of all of the sidebar instances combined
    @@generated = nil
    
    # Iterate through all of the side bar instances, render them and return as HTML
    def self.render_all
      if @@generated == nil
        retval = []
        # Remove any sidebar content which is not in the sidebar list
        @@content.delete_if do |item|
          WhoNeedsWP::options[:sidebar].index(item.class.to_s.match(/::(.*)/)[1]) == nil
        end
        # Order the sidebar content based on the order in the option
        @@content.sort! { |a, b|
          a_classname = a.class.to_s.match(/::(.*)/)[1]
          b_classname = b.class.to_s.match(/::(.*)/)[1]
          a = WhoNeedsWP::options[:sidebar].index(a_classname)
          b = WhoNeedsWP::options[:sidebar].index(b_classname)
          a <=> b
        }
        @@content.each do |content|
          retval << content.render
        end
        @@generated = retval.join
      end
      return @@generated
    end

    # Create a new instance of this sidebar
    def initialize
      @logger = Logger.new(STDOUT)
      @@content << self
    end

    # Render this peice of sidebar content. Returns HTML.
    def render
      # To be implemented.
    end
  end
end
