
module WhoNeedsWP
  def self.load_posts
    @POSTS = []
    Dir.glob('posts/**/*.markdown').each do |filename|
      @logger.debug "Loading post #{filename}"
      match = filename.match(/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/([^\.]*)/)
      date = DateTime.new(match[1].to_i, match[2].to_i, match[3].to_i)
      @POSTS << {
        :filename => { 
          :original => filename,
          :generated => File.dirname(filename) + "/" + File.basename(filename, ".markdown") + ".html"
        },
        :title => match[4].gsub(/_/, ' '),
        :created_at => date
      }
    end
    @POSTS.sort! { |a, b| a[:created_at] <=> b[:created_at] }
    @POSTS.reverse!
  end


  def self.recentposts
    @sidebar << @template['recentposts'].render(Object.new, { 
                                                 :posts => @POSTS[0..5], 
                                                 :options => @options
                                               })
  end

  def self.generate_posts
    @POSTS.each do |post|
      File.open(post[:filename][:generated], "w") do |file|
        markdown = File.read(post[:filename][:original])
        post[:author] = @options[:author]
        match = markdown.match(/^[aA]uthor: (.*)$/o)
        if match
          post[:author] = match[1]
          # Remove the author from the post text
          markdown.gsub! /^[aA]uthor: .*$/, ''
        end
#        post[:markdown] = RDiscount.new(markdown, :smart, :generate_toc).to_html
        post[:markdown] = MakersMark.generate(markdown)
        post[:html] = @template['post'].render(Object.new, {
                                                :post => post, 
                                                :title => post[:title],
                                                :options => @options
                                              })
        file.puts @template['layout'].render(Object.new, {
                                              :content => post[:html], 
                                              :options => @options, 
                                              :title => post[:title], 
                                              :sidebar => @sidebar.join
                                            })
      end
    end
  end
end
