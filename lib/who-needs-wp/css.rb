
module WhoNeedsWP
  def self.css(filename="style.css")
    if @options[:stylesheet] == nil or @options[:stylesheet].empty?
    stylesheets_folder = File.expand_path(File.join(File.dirname(__FILE__), "stylesheets"))
    @logger.debug "Generating stylesheets from #{stylesheets_folder}"
    File.open(filename, "w") do |file|
      file.puts Sass::Engine.new(File.read("#{stylesheets_folder}/style.sass"), { :load_paths => [stylesheets_folder]}).to_css
    end
    end
  end
end
