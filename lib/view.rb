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

  def initialize handler
    @manifest_handler = handler
  end

  def create output_dir
    assert_dir output_dir

    assert_dir "#{output_dir}/public"
    system "cp #{view_dir}/public/* #{output_dir}/public/"

    @root = ""

    render_template "index", output_dir
    render_template "about", output_dir
    render_template "get", output_dir
    render_template "contribute", output_dir

    library_path = "#{output_dir}/libraries/"
    assert_dir library_path

    @root = "../"

    manifests.each do |manifest|
      @manifest = manifest
      file_name = "libraries/" + manifest["name"]
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
    if url !~ /^mailto:/ && url !~ /^http:/ && url !~ /^https:/
      url = "#{@root}#{url}.html"
    end
    "<a href=\"#{url}\">#{title}</a>"
  end

  def manifests
    if @manifest_handler.manifests.empty?
      @manifest_handler.read_remote
    end
    @manifest_handler.manifests
  end

  def disqus_enabled?
    @enable_disqus
  end

  def more_urls?
    if @manifest["urls"]
      @manifest["urls"].each do |name,url|
        if name != "homepage" && name != "screenshots" && name != "logo"
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

end
