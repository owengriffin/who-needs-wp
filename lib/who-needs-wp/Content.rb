module WhoNeedsWP
  # Class for storing content which is rendered on the site
  class Content
    # Unique identifier of the content, can be used in RSS & Atom feeds
    attr_accessor :id
    # HTML content of the content
    attr_accessor :html
    # Original Markdown content
    attr_accessor :markdown
    # Title of the content derived from the filename
    attr_accessor :title
    # Author of the content
    attr_accessor :author
    # The full URL of this peice of content
    attr_accessor :url
    # A tiny URL which can be used when referring to this content
    attr_accessor :tiny_url
    # A short summary of this content, normally first paragraph
    attr_accessor :summary
    # A Hash which contains the original and generated filename
    attr_accessor :filename
    # An array of tags which are associated with this content
    attr_accessor :tags

    def initialize(filename)
      @filename = {
        :original => filename,
        :generated => generate_filename(filename)
      }
      @title = generate_title(filename)
      @url = WhoNeedsWP::options[:url] + '/' + @filename[:generated]
      # Set the default author of the content to be the site author
      @author = WhoNeedsWP::options[:author]
      
      read_file
    end

    # Render this peice of content
    def render
      # Set the summary to be the first paragraph
      @summary = $1 if @html =~ (/(?:<p>)(.*?)(?:<\/p>)/m)
      # Append the full site URL to any links referring to the root folder
      @html.gsub!(/(href|src)=\"\//, '\1="' + WhoNeedsWP::options[:url] + '/')
      # Render the content HTML within a page
      WhoNeedsWP::render_html(@filename[:generated], "page", @html, @title, @tags, @summary)
    end

    private

    # Read the content from the filename
    def read_file
      content = File.read(@filename[:original])
      # Remove the author, if there is one from the Markdown
      content = extract_author(content)
      content = extract_summary(content)
      if WhoNeedsWP::options[:use_term_extractor]
        @tags = YahooTermExtractor.generate_keywords(content)
      elsif WhoNeedsWP::options[:extract_tags]
        content = extract_tags(content)
      else
        @tags = []
      end

      @markdown = Kramdown::Document.new(content)
      #,{:coderay => {:wrap => :div, :line_numbers => :inline,
    #:line_number_start => 1, :tab_width => 8, :bold_every => 10, :css => :style}})
    end

    # Return the title of the content, based on the filename
    def generate_title(filename)
      match = filename.match(/.*\/(.*)\.[^\.]*$/)
      return match[1].gsub(/_/, ' ')
    end

    # Return the filename which will be use to save rendered content
    def generate_filename(filename)
      File.dirname(filename) + "/" + File.basename(filename, ".markdown").gsub(/[?\/]/, '') + ".html"
    end

    # Generate a unique ID for this content
    def generate_id
      if @created_at != nil
        # Replace the HTTP from the URL with tag:
        @id = (WhoNeedsWP::options[:url] + '/' + @filename[:generated]).gsub(/http:\/\//, 'tag:')
        match = @id.match(/([^\/]*)\/(.*)/)
        @id = "#{match[1]},#{self.created_at.strftime('%Y-%m-%d')}:#{match[2]}" if match
      end
    end

    # Read the author from the Markdown content. If none exists
    # then set the default author.
    def extract_author(content)
      match = content.match(/^[aA]uthor: (.*)$/o)
      if match
        @author = match[1]
        # Remove the author from the post text
        content.gsub! /^[aA]uthor: .*$/, ''
      end
      return content
    end

    # Read any tags / keywords from the Markdown content.
    def extract_tags(content)
      match = content.match(/^[tT]ags: (.*)$/o)
      if match
        @tags = match[1].split.collect! {|tag| tag.downcase }
        # Remove the author from the post text
        content.gsub! /^[tT]ags: .*$/, ''
      else
        @tags = []
      end
      return content
    end

    # Extract the summary from the Markdown content
    def extract_summary(content)
      match = content.match(/^[sS]ummary: (.*)$/o)
      if match
        @summary = match[1]
        content.gsub! /^[sS]ummary: .*$/, ''
      end
      return content
    end
  end
end
