require 'nokogiri'

module WhoNeedsWP
  class Delicious < Sidebar
    # Create a new Delicious sidebar
    def initialize(username)
      super()
      @username = username
      validate_options
    end

    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("delicious", { :posts => get_bookmarks })
    end

    private

    # Ensure that the Delicious username is set
    def validate_options
      if @username == nil or @username.empty?
        raise "You need to provide a Delicious username"
      end
    end

    # Return a list of bookmarks from Delicious
    def get_bookmarks
      @logger.debug "Fetching bookmarks from Delicious"
      bookmarks = []
      doc = REXML::Document.new(open("http://feeds.delicious.com/v2/rss/#{@username}?count=5"))
      doc.each_element('//channel/item') do |item|
        bookmarks << {
          :title => item.get_text('title'),
          :url => item.get_text('link'),
          :date => Date.parse(item.get_text('pubDate').to_s)
        }
      end
      return bookmarks
    end
  end
end
