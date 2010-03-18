
module WhoNeedsWP
  
  def self.parse_tweet(text)
    text = text.gsub(/(http:\/\/[^ ]+)/, '<a href="\1">\1</a>')
    text = text.gsub(/(@([^ :]+))/, '<a href="http://twitter.com/\2">\1</a>')
    return text.gsub(/(#([^ :]+))/, '<a href="http://twitter.com/#search?q=%23\2">\1</a>')
  end
  
  def self.twitter
    @logger.debug @options[:twitter]
    if @options[:twitter][:user]
      @logger.debug "Reading Tweets for user #{@options[:twitter][:user]}"
      @sidebar << @template['twitter'].render(Object.new, { 
                                                :tweets => Twitter::Search.new.from(@options[:twitter][:user]).per_page(5).fetch().results,  
                                                :feed_title => "@#{@options[:twitter][:user]}",
                                                :options => @options
                                              })
    end
    if @options[:twitter][:search]
      @logger.debug "Searching Twitter for #{@options[:twitter][:search]}"
      @sidebar << @template['twitter'].render(Object.new, { 
                                                :tweets => Twitter::Search.new(@options[:twitter][:search]).per_page(5).fetch().results, 
                                                :feed_title => "Tweets for \"#{@options[:twitter][:search]}\"",
                                                :options => @options
                                              })
    end
  end
end
