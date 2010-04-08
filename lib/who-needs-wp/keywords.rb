
module WhoNeedsWP

  class YahooTermExtractor
    @@API_URI = URI.parse('http://api.search.yahoo.com/ContentAnalysisService/V1/termExtraction')
    def self.generate_keywords(text)
      return [] if text.empty? 
      keywords = []
      i = Net::HTTP.post_form(@@API_URI, { 'appid' => 'who-needs-wp', 'context' => text  } )
      i = REXML::Document.new i.body
      i.each_element("//Result") do |result| 
        keywords << result.text
      end
      return keywords
    end
  end
end
