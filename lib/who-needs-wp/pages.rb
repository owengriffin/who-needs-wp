
module WhoNeedsWP
  def self.load_pages
    @pages = []
    Dir.glob('pages/*.markdown').each do |filename|
      @logger.debug "Loading page #{filename}"
      match = filename.match(/.*\/([^\.]*)/)
      @pages << {
        :filename => { 
          :original => filename,
          :generated => File.dirname(filename) + "/" + File.basename(filename, ".markdown") + ".html"
        },
        :title => match[1].gsub(/_/, ' ')
      }
    end
  end


  def self.page_index
    @sidebar << @template['pageindex'].render(Object.new, { 
                                                 :pages => @pages, 
                                                 :options => @options
                                               })
  end

  def self.generate_pages
    @pages.each do |page|
      File.open(page[:filename][:generated], "w") do |file|
        markdown = File.read(page[:filename][:original])
        page[:author] = @options[:author]
        match = markdown.match(/^[aA]uthor: (.*)$/o)
        if match
          page[:author] = match[1]
          # Remove the author from the post text
          markdown.gsub! /^[aA]uthor: .*$/, ''
        end
#        post[:markdown] = RDiscount.new(markdown, :smart, :generate_toc).to_html
        page[:markdown] = MakersMark.generate(markdown)
        page[:html] = @template['page'].render(Object.new, {
                                                :page => page, 
                                                :title => page[:title],
                                                :options => @options
                                              })
        file.puts @template['layout'].render(Object.new, {
                                              :content => page[:html], 
                                              :options => @options, 
                                              :title => page[:title], 
                                              :sidebar => @sidebar.join,
                                               :layout_name => "page"
                                            })
      end
    end
  end
end
