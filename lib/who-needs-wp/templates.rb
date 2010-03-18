

module WhoNeedsWP

  # Render the specified HTML contents within the layout template
  def self.render_html(filename, type, contents, title = @options[:title])
    File.open(filename, "w") do |file|
      body = @template['body'].render(Object.new, {
                                              :content => contents, 
                                              :options => @options, 
                                              :sidebar => @sidebar.join,
                                               :layout_name => type
                                            })
      file.puts @template['layout'].render(Object.new, {
                                             :content => body,
                                             :options => @options,
                                             :title => title 
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
