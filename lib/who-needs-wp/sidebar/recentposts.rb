module WhoNeedsWP
  # A sidebar component to display a list of recent posts
  class RecentPosts < Sidebar
    # See Sidebar.render
    def render
      WhoNeedsWP::render_template("recentposts", { :posts => WhoNeedsWP::get_posts[0..5] })
    end
  end
end
