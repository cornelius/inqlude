require "nokogiri"
require "open-uri"
require 'csv'

require_relative "../../lib/inqlude"

s = Settings.new
s.offline = true
mh = ManifestHandler.new s
mh.read_remote
v = View.new mh
output_dir = File.join(File.dirname(__FILE__), 'test_views')

v.render_template "index", output_dir

html_data = File.read(File.join(output_dir, 'index.html'))
nokogiri_object = Nokogiri::HTML(html_data)
library_elements = nokogiri_object.xpath("//td[@class='first']/a")

CSV.open( File.join(output_dir, 'libraries.csv'), 'w') do |csv|
	csv << library_elements
end
