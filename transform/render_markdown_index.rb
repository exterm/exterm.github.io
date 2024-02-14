require 'json'
require 'pathname'

input_dir = Pathname.new(ARGV[0])
output_file = Pathname.new(ARGV[1])
here = Pathname.new(__FILE__).dirname.expand_path

post_mds = Pathname.glob(input_dir + '*.md')

post_metadata = post_mds.map do |md|
  root = here.parent
  path_from_root = md.relative_path_from(root)
  root_from_here = root.relative_path_from(here)
  metadata_json = `pandoc --template=#{root_from_here}/transform/pandoc/templates/metadata.tpl #{md}`.strip
  metadata = JSON.parse(metadata_json)

  metadata['date'] = md.basename.to_s.split('-')[0..2].join('-')
  [path_from_root, metadata]
end

post_metadata.sort_by! { |md, metadata| metadata['date'] }.reverse!

`mkdir -p #{output_file.dirname}`

File.open(output_file, 'w') do |f|
  post_metadata.each do |md, metadata|
    f.puts "* _#{metadata['date']}:_ [#{metadata['title']}](posts/#{md.basename.sub_ext("")})"
  end
end
