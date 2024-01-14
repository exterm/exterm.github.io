require "nokogiri"
require "date"
require "pathname"

# render a sitemap from all post sources (markdown files)

input_dir = Pathname.new(ARGV[0])
output_file = Pathname.new(ARGV[1])

DOMAIN = "https://simplexity.quest"

def git_mtime(path)
  DateTime.parse(%x(git log -1 --pretty="format:%ci" #{path}).strip)
end

all_mds = Pathname.glob(input_dir + "*.md")

Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
  xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") {
    xml.url {
      xml.loc(DOMAIN + "/")
      # last modification for the index is the latest of all posts
      latest_page = all_mds.map { |path| git_mtime(path) }.max
      xml.lastmod latest_page.iso8601
    }
    all_mds.each do |path|
      xml.url {
        dir, file = path.each_filename.to_a[-2, 2]
        xml.loc "#{DOMAIN}/#{dir}/#{File.basename(file, ".md")}.html"
        xml.lastmod git_mtime(path).iso8601
      }
    end
  }
end.to_xml.tap do |xml|
  File.write(output_file, xml)
end
