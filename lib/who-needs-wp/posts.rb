
module WhoNeedsWP
  def self.load_posts
    @POSTS = []
    Dir.glob('posts/**/*.markdown').each do |filename|
      @logger.debug "Loading post #{filename}"
      match = filename.match(/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/([^\.]*)/)
      date = DateTime.new(match[1].to_i, match[2].to_i, match[3].to_i)
      generated_filename = File.dirname(filename) + "/" + File.basename(filename, ".markdown") + ".html" 
      post = {
        :filename => { 
          :original => filename,
          :generated => generated_filename,
        },
        :title => match[4].gsub(/_/, ' '),
        :created_at => date
      }
      # Generate a unique post ID to be used in the Atom feed
      post[:id] = "#{options[:url]}#{generated_filename}".gsub!(/http:\/\//, 'tag:')
      match = post[:id].match(/([^\/]*)\/(.*)/)
      post[:id] = "#{match[1]},#{date.strftime('%Y-%m-%d')}:#{match[2]}" if match
      # Append the post to the global list of posts
      @POSTS << post
    end
    # Sort the posts, newest first
    @POSTS.sort! { |a, b| a[:created_at] <=> b[:created_at] }
    @POSTS.reverse!
  end


  def self.recentposts
    @sidebar << @template['recentposts'].render(Object.new, { 
                                                 :posts => @POSTS[0..5], 
                                                 :options => @options
                                               })
  end

  def self.options
    return @options
  end

  def self.POSTS
    return @POSTS
  end

  def self.rss(filename, limit=10)
    file = File.open(filename, "w")
    file.write @template['rss'].render(Object.new, { 
                                                 :posts => @POSTS[0..limit], 
                                                 :options => @options
                                               })
    file.close
  end

  def self.atom(filename, limit=10)
    file = File.open(filename, "w")
    file.write @template['atom'].render(Object.new, { 
                                                 :posts => @POSTS[0..limit], 
                                                 :options => @options
                                               })
    file.close
  end

  def self.generate_posts
    @POSTS.each_index do |index|
      # Calculate the previous and next posts
      post = @POSTS[index]
      previous_post = @POSTS[index + 1] if index + 1 < @POSTS.length
      next_post = @POSTS[index - 1] if index > 1

      # Read the contents of the file
      markdown = File.read(post[:filename][:original])
      
      # Specify the default author
      post[:author] = @options[:author]

      # Check to see if the author of the document is specified with "Author:"
      match = markdown.match(/^[aA]uthor: (.*)$/o)
      if match
        post[:author] = match[1]
        # Remove the author from the post text
        markdown.gsub! /^[aA]uthor: .*$/, ''
      end

      # post[:markdown] = RDiscount.new(markdown, :smart, :generate_toc).to_html
      post[:markdown] = MakersMark.generate(markdown)
      post[:html] = @template['post'].render(Object.new, {
                                               :post => post, 
                                               :title => post[:title],
                                               :options => @options,
                                               :next_post => next_post,
                                               :previous_post => previous_post
                                             })
      # Set the summary of the post to be the first paragraph
      match = post[:html].match(/(?:<p>)(.*?)(?:<\/p>)/)
      if match
        @logger.debug match.inspect
        post[:summary] = $1
      end
      
      # Render the post as HTML
      self.render_html(post[:filename][:generated], "post", post[:html], post[:title])
    end
  end
end
