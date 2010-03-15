

module WhoNeedsWP
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
