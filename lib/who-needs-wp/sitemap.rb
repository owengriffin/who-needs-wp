
module WhoNeedsWP
  def self.sitemap
    document = REXML::Document.new
    urlset = document.add_element("urlset", { "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9"})
    Post.all.each do |post|
      url = REXML::Element.new("url")
      urlset.add(url)
      url.add_element("loc").text = post.url
      url.add_element("lastmod").text = post.created_at.strftime('%Y-%m-%d')
      url.add_element("priority").text = "0.5"
    end
    Page.all.each do |page|
      url = REXML::Element.new("url")
      urlset.add(url)
      url.add_element("loc").text = page.url
      url.add_element("priority").text = "0.8"
    end
    
    # Generate sitemap for index page
    url = REXML::Element.new("url")
    
    url.add_element("loc").text = WhoNeedsWP::options[:url] + "/index.html"
    if Post.all.length > 0 
      url.add_element("lastmod").text = Post.all[0].created_at.strftime('%Y-%m-%d')
    end
    url.add_element("priority").text = "1.0"
    urlset.add(url)

    # Write the XML document to a file
    File.open("sitemap.xml", "w") do |file|
      file.puts document
    end

    # Create a robots.txt which points to the sitemap.xml
    File.open("robots.txt", "w") do |file|
      file.puts "Sitemap: #{WhoNeedsWP::options[:url]}sitemap.xml"
    end
  end
end
