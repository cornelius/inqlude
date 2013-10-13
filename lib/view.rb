# Copyright (C) 2011 Cornelius Schumacher <schumacher@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class View

  attr_accessor :enable_disqus
  attr_accessor :enable_search
  attr_reader :root
  
  def initialize handler
    @manifest_handler = handler
  end

  def create output_dir
    puts "Creating web site in '#{output_dir}' from '#{@manifest_handler.settings.manifest_path}'"
    
    assert_dir output_dir

    assert_dir "#{output_dir}/public"
    system "cp #{view_dir}/public/* #{output_dir}/public/"
    
    assert_dir "#{output_dir}/schema"
    system "cp #{schema_dir}/* #{output_dir}/schema"

    @root = ""

    render_template "index", output_dir
    render_template "development", output_dir
    render_template "about", output_dir
    render_template "get", output_dir
    render_template "contribute", output_dir
    render_template "search", output_dir

    library_path = "#{output_dir}/libraries/"
    assert_dir library_path

    @root = "../"

    @manifest_handler.libraries.each do |library|
      @library = library
      @manifest = library.manifests.last
      file_name = "libraries/" + library.name
      render_template "library", output_dir, file_name
    end
  end

  def render_template name, output_dir, file_name = nil
    layout = template "layout"
    layout_engine = Haml::Engine.new layout

    page = template name
    @content = Haml::Engine.new( page ).render( binding )

    output_path = ""
    if file_name
      output_path = "#{output_dir}/#{file_name}.html"
    else
      output_path = "#{output_dir}/#{name}.html"
    end

    File.open output_path, "w" do |file|
      file.puts layout_engine.render( binding )
    end
  end

  def yank
    @content
  end

  def style_sheet
    "<link href='#{@root}public/inqlude.css' rel='stylesheet' type='text/css' />"
  end

  def m attr, subattr = nil
    if subattr
      @manifest[ attr ][ subattr ]
    else
      @manifest[ attr ]
    end
  end

  def link_to_manifest name
    "<a href=\"libraries/#{name}.html\">#{name}</a>"
  end

  def link url
    "<a href=\"#{url}\" target=\"_blank\">#{url}</a>"
  end

  def link_to title, url
    if url !~ /^mailto:/ && url !~ /^http:/ && url !~ /^https:/ && url !~ /^ftp:/
      url = "#{@root}#{url}.html"
    end
    "<a href=\"#{url}\">#{title}</a>"
  end

  def list_attribute attribute
    attr = m attribute
    return "" if !attr || attr.size == 0

    # We assume attribute is plural formed by adding an 's'

    label = attribute.capitalize

    entries = Array.new
    attr.each do |a|
      entries.push markup_email( a )
    end

    if attr.size > 1
      return list_attribute_content label, entries.join(", ")
    else
      return list_attribute_content label[0..-2], entries.first
    end
  end

  def list_attribute_content label, value
    out = "<div class='attribute'>"
    out += "  <div class='label'>" + label + ":" + "</div>"
    out += "  <div class='value'>" + value + "</div>"
    out += "</div>"
    out
  end

  def version_content
    out = @manifest["version"]
    out += " (#{@manifest["maturity"]})"
    out += "<span class='release-date'>"
    out += "released on #{@manifest["release_date"]}"
    out += "</span>"
    if !old_versions.empty?
      out += "<span class='old-versions'>"
      out += "(older versions: #{old_versions.join(", ")})"
      out += "</span>"
    end
    out
  end
  
  def markup_email email
    if email =~ /(.*) <(.*)>/
      name = $1
      email = $2
      
      return "<a href=\"mailto:#{email}\">#{name}</a>"
    else
      return email
    end
  end

  def link_item key, label
    if m( "urls", key )
      out = "<li><a href=\""
      out += m( "urls", key )
      out += "\">#{label}</a>"
      return out
    else
      return ""
    end
  end

  def custom_urls
    out = ""
    urls = m "urls", "custom"
    if urls && !urls.empty?
      urls.each do |text,url|
        out += "<li><a href=\"#{url}\">#{text}</a></li>"
      end
    end
    out
  end
  
  def libraries maturity = nil
    if @manifest_handler.libraries(maturity).empty?
      @manifest_handler.read_remote
    end
    @manifest_handler.libraries(maturity)
  end

  def disqus_enabled?
    @enable_disqus
  end

  def more_urls?
    if @manifest["urls"]
      @manifest["urls"].each do |name,url|
        if name != "homepage" && name != "screenshots" && name != "logo" && name != "description_source"
          return true
        end
      end
    end
    return false
  end
  
  def editor_url
    url = "https://github.com/cornelius/inqlude-data/blob/master/"
    url += @manifest["name"]
    url += "/#{@manifest["name"]}.#{@manifest["release_date"]}.manifest"
    url
  end

  def old_versions
    versions = Array.new
    count = @library.manifests.count
    if count > 1
      versions = @library.manifests[0..count-2].map {|m| m["version"] }
    end
    versions.reverse
  end

  private
  
  def assert_dir name
    Dir::mkdir name unless File.exists? name
  end    
  
  def template name
    File.read( view_dir + "#{name}.html.haml" )
  end

  def view_dir
    File.expand_path( File.dirname( __FILE__ ) + "/../view/" ) + "/"
  end

  def schema_dir
    File.expand_path( File.dirname( __FILE__ ) + "/../schema/" ) + "/"
  end

end
