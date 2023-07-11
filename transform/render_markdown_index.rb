require 'json'
require 'pathname'

post_mds = Dir.glob(File.join(File.dirname(__FILE__), '..', 'content', 'posts', '*.md'))

post_metadata = post_mds.map do |md|
  md = Pathname.new(md)
  root = Pathname.new(File.join(File.dirname(__FILE__), '..'))
  path_from_root = md.relative_path_from(root)
  root_from_here = root.relative_path_from(File.dirname(__FILE__))
  metadata_json = `pandoc --template=#{root_from_here}/transform/pandoc/templates/metadata.tpl #{md}`.strip
  metadata = JSON.parse(metadata_json)

  metadata['date'] = md.basename.to_s.split('-')[0..2].join('-')
  [path_from_root, metadata]
end

post_metadata.sort_by! { |md, metadata| metadata['date'] }.reverse!

`mkdir -p #{File.join(File.dirname(__FILE__), '..', 'generated')}`

File.open(File.join(File.dirname(__FILE__), '..', 'generated', 'index.md'), 'w') do |f|
  post_metadata.each do |md, metadata|
    f.puts "* _#{metadata['date']}_: [#{metadata['title']}](posts/#{md.basename.sub_ext('.html')})"
  end
end
