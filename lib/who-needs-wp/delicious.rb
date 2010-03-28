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
      doc = Nokogiri::XML(open("http://feeds.delicious.com/v2/rss/#{@username}?count=5"))
      doc.xpath('//channel/item').each do |item|
        bookmarks << {
          :title => (item/'title').first.content,
          :url => (item/'link').first.content,
          :date => Date.parse((item/'pubDate').first.content)
        }
      end
      return bookmarks
    end
  end
end
