module WhoNeedsWP
  # A sidebar component to display a list of pages
  class PageIndex < Sidebar
    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("pageindex", { :pages => WhoNeedsWP::Page.all })
    end
  end
end
