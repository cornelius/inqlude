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

require "rubygems"

require "haml"

class View

  attr_accessor :enable_disqus

  def initialize handler
    @manifest_handler = handler
  end

  def create output_dir
    assert_dir output_dir

    assert_dir "#{output_dir}/public"
    system "cp #{view_dir}/public/* #{output_dir}/public/"

    index = template "index"
    engine = Haml::Engine.new index

    File.open "#{output_dir}/index.html", "w" do |file|
      file.puts engine.render( binding )
    end

    library_path = "#{output_dir}/libraries/"
    assert_dir library_path

    engine = Haml::Engine.new template "library"

    manifests.each do |manifest|
      File.open library_path + manifest["name"] + ".html", "w" do |file|
        @manifest = manifest
        file.puts engine.render( binding )
      end
    end

  end

  def m attr
    @manifest[ attr ]
  end

  def link_to_manifest name
    "<a href=\"libraries/#{name}.html\">#{name}</a>"
  end

  def link url
    "<a href=\"#{url}\" target=\"_blank\">#{url}</a>"
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
