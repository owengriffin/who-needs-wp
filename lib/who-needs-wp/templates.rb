module WhoNeedsWP
  # Render the specified template with the given options
  def self.render_template(name, data)
    data[:options] = @options
    @template[name].render(Object.new, data)
  end

  # Render the specified HTML contents within the layout template
  def self.render_html(filename, type, contents, title = "", tags = [], summary = "")
    File.open(filename, "w") do |file|
      body = @template['body'].render(Object.new, {
        :content => contents,
        :options => @options,
        :sidebar => Sidebar.render_all,
        :layout_name => type
      })
      file.puts @template['layout'].render(Object.new, {
        :content => body,
        :options => @options,
        :title => title,
        :tags => tags,
        :summary => summary
      })
    end
  end

  def self.load_templates
    template_folder = File.expand_path(File.join(File.dirname(__FILE__), "templates"))
    @template = Hash.new
    Dir.glob("#{template_folder}/*.haml").each do |template|
      # If a local template exists then over-write
      if File.exists? "templates/#{File.basename(template)}"
        template = "templates/#{File.basename(template)}"
      end
      @logger.debug "Loading template #{template}"
      @template[File.basename(template, '.haml')] = Haml::Engine.new(File.read(template))
    end
  end
end
