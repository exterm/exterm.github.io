require "nokogiri"
require "date"

# render a sitemap from all post sources (markdown files)

DOMAIN = "https://simplexity.quest"
TARGET = "../generated/public/sitemap.xml"

Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
  xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") {
    xml.url {
      xml.loc "https://simplexity.quest/"
      # last modification for the index is the latest of all posts
      latest_post = Dir.glob("../content/posts/**/*.md").map { |path| File.mtime(path).to_datetime }.max
      xml.lastmod latest_post.iso8601
    }
    Dir.glob("../content/posts/*.md").each do |path|
      xml.url {
        xml.loc "#{DOMAIN}/posts/#{File.basename(path, ".md")}.html"
        xml.lastmod File.mtime(path).to_datetime.iso8601
      }
    end
  }
end.to_xml.tap do |xml|
  File.write(TARGET, xml)
end
