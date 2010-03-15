
module WhoNeedsWP
  def self.twitter
    if @options[:twitter][:user]
      @sidebar << @template['twitter'].render(Object.new, { 
                                                :tweets => Twitter::Search.new(@options[:twitter][:user]).per_page(5).fetch().results, 
                                                :options => @options
                                              })
    end
  end
end
