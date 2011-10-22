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

class ManifestHandler

  attr_reader :manifests, :libraries
  
  def initialize settings
    @settings = settings

    @libraries = Array.new
    @manifests = Array.new
  end

  def manifest name
    read_remote
    @libraries.each do |library|
      if library.name == name
        return library.manifests.last
      end
    end
    nil
  end

  def read_remote
    if !@settings.offline
      fetch_remote
    end

    Dir.glob( "#{@settings.manifest_path}/*" ).sort.each do |dirname|
      next if !File.directory?( dirname )

      library = Library.new
      library.name = File.basename dirname
      local_manifests = Array.new
      Dir.glob( "#{dirname}/*.manifest" ).sort.each do |filename|
        File.open filename do |file|
          manifest = JSON file.read
          manifest["filename"] = File.basename filename
          manifest["libraryname"] = library.name
          local_manifests.push manifest
          manifests.push manifest
        end
      end
      library.manifests = local_manifests
      libraries.push library
    end
  end

  def fetch_remote
    if !File.exists? @settings.manifest_path + "/.git"
      if File.exists? @settings.manifest_path
        system "rm -r #{@settings.manifest_path}"
      end
      system "git clone https://github.com/cornelius/inqlude-data.git " +
        "#{@settings.manifest_path}"
    else
      system "cd #{@settings.manifest_path}; git pull"
    end
  end

end
