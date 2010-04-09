module WhoNeedsWP
  class Latitude < Sidebar
    def initialize(username)
      super()
      @username = username
    end

     # See Sidebar.render
    def render
      @logger.debug "Rendering Latitude iFrame"
      WhoNeedsWP::render_template("latitude", { :username => @username })
    end
  end
end
