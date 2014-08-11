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

  def is_new?
    return !File.exists?( @dir )
  end
  
  def validate_directory
    if !File.exists? @dir
      raise "Unable to find manifest directory '#{@dir}'"
    end
  end

  def update version, release_date
    filename = File.join @settings.manifest_path, @name,
      "#{@name}.#{release_date}.manifest"
    
    mh = ManifestHandler.new @settings
    mh.read_remote

    m = mh.manifest @name
    m.version = version
    m.release_date = release_date
    
    File.open( filename, "w" ) do |file|
      file.puts Manifest.to_json(m)
    end
  end

  def create_dir
    FileUtils.mkdir_p File.join(@settings.manifest_path,@name)
  end

  def create_manifest version, release_date
    m = ManifestRelease.new
    m.name = @name
    m.version = version
    m.release_date = release_date
    if version == "edge"
      m.maturity = "edge"
    else
      m.maturity = "stable"
    end
    m.platforms = [ "Linux" ]
    m
  end

  def write_manifest manifest
    filename = File.join @settings.manifest_path, @name, @name
    if manifest.release_date
      filename += ".#{manifest.release_date}"
    end
    filename += ".manifest"

    File.open( filename, "w" ) do |file|
      file.puts Manifest.to_json(manifest)
    end
  end
  
  def create_generic_manifest
    m = ManifestGeneric.new
    m.name = @name
    m.display_name = @name.capitalize
    m.platforms = [ "Linux" ]
    m
  end

  def create_generic
    create_dir
    m = create_generic_manifest
    write_manifest m
  end
  
  def create version, release_date
    create_dir
    m = create_manifest version, release_date
    write_manifest m
  end

  def create_kf5 version, release_date
    create_dir

    m = create_manifest version, release_date

    m["authors"] = [ "The KDE Community" ]
    m["licenses"] = [ "LGPLv2.1+" ]

    vcs = "https://projects.kde.org/projects/kde/kdelibs/repository/revisions/frameworks/show/tier1/"
    vcs += @name
    m["urls"] = {
      "vcs" => vcs,
      "homepage" => "http://community.kde.org/Frameworks"
    }
    
    m["packages"] = {
      "source" => "http://anongit.kde.org/kdelibs/kdelibs-latest.tar.gz"
    }

    write_manifest m
  end

end
