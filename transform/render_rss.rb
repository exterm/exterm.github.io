require "nokogiri"
require "date"
require "pathname"

# render an RSS feed from all post sources (markdown files)

input_dir = Pathname.new(ARGV[0])
output_file = Pathname.new(ARGV[1])

DOMAIN = "https://simplexity.quest"
TITLE = "Simplexity Quest"

def git_mtime(path)
  DateTime.parse(%x(git log -1 --pretty="format:%ci" #{path}).strip)
end

all_mds = Pathname.glob(input_dir + "*.md")

Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
  xml.rss(version: "2.0") {
    xml.channel {
      xml.title TITLE
      xml.link(DOMAIN + "/")
      xml.description TITLE
      latest_post = all_mds.map { |path| git_mtime(path) }.max
      xml.pubDate latest_post.iso8601
      all_mds.each do |path|
        xml.item {
          xml.link "#{DOMAIN}/posts/#{path.basename(".md")}.html"
          xml.pubDate git_mtime(path).iso8601
        }
      end
    }
  }
end.to_xml.tap do |xml|
  File.write(output_file, xml)
end
