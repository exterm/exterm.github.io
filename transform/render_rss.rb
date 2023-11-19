require "nokogiri"
require "date"
require "pathname"
require "json"

# render an RSS feed from all post sources (markdown files)

input_dir = Pathname.new(ARGV[0])
output_file = Pathname.new(ARGV[1])

all_mds = Pathname.glob(input_dir + "*.md")

DOMAIN = "https://simplexity.quest"
TITLE = "Simplexity Quest"

def git_mtime(path)
  DateTime.parse(%x(git log -1 --pretty="format:%ci" #{path}).strip)
end

def extract_title(path)
  here = Pathname.new(__FILE__).dirname.expand_path
  JSON.parse(%x(pandoc --template=#{here + "pandoc/templates/metadata.tpl"} #{path}))["title"]
end

Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
  xml.rss(version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom") {
    xml.channel {
      xml.title TITLE
      xml.link(DOMAIN + "/")
      xml["atom"].link href: DOMAIN + "/rss.xml", rel: "self", type: "application/rss+xml"
      xml.description TITLE
      latest_post = all_mds.map { |path| git_mtime(path) }.max
      xml.pubDate latest_post.rfc822
      all_mds.each do |path|
        xml.item {
          xml.title extract_title(path)
          link = "#{DOMAIN}/posts/#{path.basename(".md")}.html"
          xml.link link
          xml.guid link
          xml.pubDate git_mtime(path).rfc822
        }
      end
    }
  }
end.to_xml.tap do |xml|
  File.write(output_file, xml)
end
