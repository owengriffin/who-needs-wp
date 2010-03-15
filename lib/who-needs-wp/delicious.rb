
module WhoNeedsWP
  def self.delicious
    if @options[:delicious]
      delicious = []
      doc = Nokogiri::XML(open("http://feeds.delicious.com/v2/rss/#{@options[:delicious][:user]}?count=5"))
      doc.xpath('//channel/item').each do |item|
        delicious << {
          :title => (item/'title').first.content,
          :url => (item/'link').first.content,
          :date => Date.parse((item/'pubDate').first.content)
        }
      end
      @sidebar << @template['delicious'].render(Object.new, { 
                                                  :posts => delicious, 
                                                  :options => @options
                                                })
    end
  end
end
