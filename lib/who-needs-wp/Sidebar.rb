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
