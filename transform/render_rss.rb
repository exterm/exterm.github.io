require "nokogiri"
require "date"

# render an RSS feed from all post sources (markdown files)

DOMAIN = "https://simplexity.quest"
TARGET = "../generated/public/rss.xml"
TITLE = "Simplexity Quest"

def git_mtime(path)
  DateTime.parse(%x(git log -1 --pretty="format:%ci" #{path}).strip)
end

Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
  xml.rss(version: "2.0") {
    xml.channel {
      xml.title TITLE
      xml.link(DOMAIN + "/")
      xml.description TITLE
      latest_post = Dir.glob("../content/posts/**/*.md").map { |path| git_mtime(path) }.max
      xml.pubDate latest_post.iso8601
      Dir.glob("../content/posts/*.md").each do |path|
        xml.item {
          xml.link "#{DOMAIN}/posts/#{File.basename(path, ".md")}.html"
          xml.pubDate git_mtime(path).iso8601
        }
      end
    }
  }
end.to_xml.tap do |xml|
  File.write(TARGET, xml)
end
