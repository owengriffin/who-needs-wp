require 'twitter'

module WhoNeedsWP
  # A class combining all the common functions required by Twitter sidebar components
  class TwitterSidebar < Sidebar
    protected
    # Format a Tweet so that all the links appear in HTML
    def format_text(text)
      text = text.gsub(/(http:\/\/[^ ]+)/, '<a href="\1">\1</a>')
      text = text.gsub(/(@([^ :]+))/, '<a href="http://twitter.com/\2">\1</a>')
      return text.gsub(/(#([^ :]+))/, '<a href="http://twitter.com/#search?q=%23\2">\1</a>')
    end

    # Format all the tweets in the specified list
    def format_tweets(tweets)
      tweets.each do |tweet|
        tweet[:html] = format_text(tweet[:text])
      end
    end
  end

  # A Sidebar component which displays a list of a user's tweets
  class TwitterFeed < TwitterSidebar
    # Create a new Twitter sidebar based on "username"'s tweets
    def initialize(username)
      super()
      @username = username
      validate_options
    end

    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("twitter", {
        :tweets => tweets,
        :feed_title => "@#{@username}"
      })
    end

    private

    # Ensure the the Twitter username is set
    def validate_options
      if @username == nil or @username.empty?
        raise "You need to provide a Twitter username"
      end
    end

    # Return a list of tweets for the specified user
    def tweets(per_page = 5)
      return format_tweets(Twitter::Search.new.from(@username).per_page(per_page).fetch().results)
    end
  end

  # A Sidebar component which displays a twitter search term
  class TwitterSearch < TwitterSidebar
    # Create a new Twitter sidebar based on a search of "term"
    def initialize(term)
      super()
      @term = term
      validate_options
    end

    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("twitter", {
        :tweets => tweets,
        :feed_title => "Tweets for \"#{@term}\""
      })
    end

    private

    # Ensure the the Twitter search term is set
    def validate_options
      if @term == nil or @term.empty?
        raise "You need to provide a Twitter search term"
      end
    end

    # Return a list of tweets for the specified user
    def tweets(per_page = 5)
      return format_tweets(Twitter::Search.new(@term).per_page(per_page).fetch().results)
    end
  end
end
