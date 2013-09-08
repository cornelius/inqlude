# Copyright (C) 2013 Cornelius Schumacher <schumacher@kde.org>
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

class Creator

  def initialize settings, name
    @settings = settings
    @settings.offline = true
    @name = name
    @dir = File.join settings.manifest_path, name
  end
  
  def validate_directory
    if !File.exists? @dir
      raise "Unable to find manifest directory '#{@dir}'"
    end
  end

  def create version, release_date
    filename = File.join @settings.manifest_path, @name,
      "#{@name}.#{release_date}.manifest"
    
    mh = ManifestHandler.new @settings
    mh.read_remote

    m = mh.manifest @name
    m.delete "filename"
    m["version"] = version
    m["release_date"] = release_date
    
    File.open( filename, "w" ) do |file|
      file.puts JSON.pretty_generate(m)
    end
  end

end
