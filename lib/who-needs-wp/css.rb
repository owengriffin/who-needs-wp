
module WhoNeedsWP
  def self.css(filename="style.css")


    # The folder which contains the default who-needs-wp stylesheets
    stylesheets_folder = File.expand_path(File.join(File.dirname(__FILE__), "stylesheets"))

    sass = ""
    
    if @options[:reset_stylesheet]
      @logger.info "Including CSS reset stylesheet"
      sass = File.read("#{stylesheets_folder}/style.sass")
    end

    if @options[:stylesheet] != nil and not @options[:stylesheet].empty?
      @logger.info "Including #{@options[:stylesheet]}"
      sass = sass + "@import \"#{@options[:stylesheet]}\""
    end

    File.open(filename, "w") do |file|
      file.puts Sass::Engine.new(sass, { :load_paths => [stylesheets_folder, Dir.pwd]}).to_css
    end
  end
end
