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

  attr_accessor :enable_disqus,:enable_search,:manifest,:library,:group_name,:templates
  attr_reader :root

  def initialize handler
    @manifest_handler = handler
  end

  def create output_dir
    assert_dir output_dir

    system "cp #{view_dir}/favicon.ico #{output_dir}"

    if templates == "two-column"
      system "cp #{view_dir}/ios.ico #{output_dir}"
    end

    assert_dir "#{output_dir}/public"
    system "cp #{view_dir}/public/* #{output_dir}/public/"

    assert_dir "#{output_dir}/schema"
    system "cp #{schema_dir}/* #{output_dir}/schema"

    create_inqlude_all(output_dir)

    @root = ""

    Dir.glob("#{view_dir}*.html.haml") do |file|
      template_name = (File.basename file).split(".").first

      if !["layout","group","library"].include? template_name
        render_template template_name, output_dir
      end
    end

    groups_path = "#{output_dir}/groups/"
    assert_dir groups_path

    @root = "../"

    @group_name = "kde-frameworks"
    file_name = "groups/kde-frameworks"
    render_template "group", output_dir, file_name


    library_path = "#{output_dir}/libraries/"
    assert_dir library_path

    @root = "../"

    @manifest_handler.libraries.each do |library|
      @library = library
      @manifest = library.latest_manifest
      file_name = "libraries/" + library.name
      render_template "library", output_dir, file_name
    end

    if templates == 'two-column'
      topics_path = "#{output_dir}/topics/"
      assert_dir topics_path

      @root = "../"

      topics.each do |topic|
        @topic = topic
        file_name = "topics/" + topic
        render_template "topic", output_dir, file_name
      end
    end
  end

  def create_inqlude_all(output_dir)
    File.open(File.join(output_dir, "inqlude-all.json"), "w") do |f|
      f.write(@manifest_handler.generate_inqlude_all)
    end
  end

  def template_directory_exists?
    File.directory?(view_dir) ? true : false
  end

  def render_template name, output_dir, file_name = nil
    layout = template "layout"
    layout_engine = Haml::Engine.new layout

    page = template name
    @content = Haml::Engine.new( page ).render( binding )

    output_path = ""
    if file_name
      output_path = "#{output_dir}/#{file_name}.html"
      @file = file_name
    else
      output_path = "#{output_dir}/#{name}.html"
      @file = name
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

  def m
    @manifest
  end

  def t
    @topic
  end

  def link_to_manifest name
    "<a href=\"#{@root}libraries/#{name}.html\">#{name}</a>"
  end

  def link_to_library name, display_name
    "<a href=\"#{@root}libraries/#{name}.html\">#{display_name}</a>"
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

  def link_to_group name, display_name
    "<a href=\"#{@root}groups/#{name}.html\">#{display_name}</a>"
  end

  def link_to_topic name
    "<a href=\"#{@root}topics/#{name}.html\">#{name}</a>"
  end

  def list_attribute attribute
    attr = @manifest.send(attribute)
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
    if @manifest.class == ManifestGeneric
      raise InqludeError.new("Can't get version for generic manifest '#{@manifest.name}'")
    end
    out = @manifest.version
    out += " (#{@manifest.maturity})"
    out += "<span class='release-date'>"
    out += "released on #{@manifest.release_date}"
    out += "</span>"
    if !old_versions.empty?
      out += "<span class='old-versions'>"
      out += "(older versions: #{old_versions.join(", ")})"
      out += "</span>"
    end
    out
  end

  def add_footer
  if @file == "index"
    text = 'Last updated on ' + Date.today.to_s
  else
    text = ""
  end
  out = "Inqlude is a "
  out += link_to "KDE project", "http://kde.org"
  out += "|"
  out += link_to "Legal", "http://www.kde.org/community/whatiskde/impressum.php"
  out += "<span class='footer-text'>"
  out += text
  out += "</span>"
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
    if m.urls.send(key)
      out = "<li><a href=\""
      out += m.urls.send(key)
      out += "\">#{label}</a></li>"
      return out
    else
      return ""
    end
  end

  def custom_urls
    out = ""
    urls = @manifest.urls.custom
    if urls && !urls.empty?
      urls.each do |text,url|
        out += "<li><a href=\"#{url}\">#{text}</a></li>"
      end
    end
    out
  end

  def libraries maturity = nil
    @manifest_handler.libraries(maturity)
  end

  def unreleased_libraries
    @manifest_handler.unreleased_libraries
  end

  def commercial_libraries
    @manifest_handler.commercial_libraries
  end

  def latest_libraries
    @manifest_handler.latest_libraries
  end

  def group_title
    if @group_name == "kde-frameworks"
      return "KDE Frameworks"
    end
    ""
  end

  def group
    @manifest_handler.group(@group_name)
  end

  def topic name
    @manifest_handler.topic(name)
  end

  def no_of_libraries topic
    @manifest_handler.no_of_libraries(topic)
  end

  def disqus_enabled?
    @enable_disqus
  end

  def more_urls?
    @manifest.urls.class.all_keys.each do |key, type|
      if key != :homepage && key != :screenshots && key != :logo &&
         key != :description_source
        if @manifest.urls.send(key)
          return true
        end
      end
    end
    return false
  end

  def editor_url
    url = "https://github.com/cornelius/inqlude-data/blob/master/"
    url += @manifest.name
    url += "/#{@manifest.name}.#{@manifest.release_date}.manifest"
    url
  end

  def old_versions
    versions = @library.versions.reject{ |v| v == @manifest.version }
    versions.reverse
  end

  def render_description
    doc = Kramdown::Document.new(@manifest.description)
    doc.to_html
  end

  def topics
    ['API', 'Artwork', 'Bindings', 'Communication', 'Data', 'Desktop', 'Development', 'Graphics', 'Logging', 'Mobile', 'Multimedia', 'Printing', 'QML', 'Scripting', 'Security', 'Text', 'Web', 'Widgets']
  end

  private

  def assert_dir name
    Dir::mkdir name unless File.exists? name
  end

  def template name
    File.read( view_dir + "#{name}.html.haml" )
  end

  def view_dir
    File.expand_path( File.dirname( __FILE__ ) + "/../view/#{templates}" ) + "/"
  end

  def schema_dir
    File.expand_path( File.dirname( __FILE__ ) + "/../schema/" ) + "/"
  end

end
