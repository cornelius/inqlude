# Copyright (C) 2011-2013 Cornelius Schumacher <schumacher@kde.org>
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

  attr_reader :manifests, :settings

  def initialize settings
    @settings = settings

    @libraries = Array.new
    @manifests = Array.new
  end

  def manifest_path manifest
    File.join(@settings.manifest_path, manifest.path)
  end

  def libraries maturity = nil
    if !maturity
      return @libraries
    else
      return @libraries.select do |l|
        manifest = l.latest_manifest
        manifest.maturity == maturity.to_s &&
          manifest.licenses != [ "Commercial" ]
      end
    end
  end

  def unreleased_libraries
    return @libraries.select do |l|
      !l.latest_manifest.is_released?
    end
  end

  def commercial_libraries
    return @libraries.select do |l|
      manifest = l.latest_manifest
      manifest.licenses.include? "Commercial"
    end
  end

  def latest_libraries
    releases = Array.new
    is_kde_added = false

    libraries.select do |library|
      if library.latest_manifest.has_version? && library.latest_manifest.group != "kde-frameworks"
        releases.push library
      elsif library.latest_manifest.has_version? && library.latest_manifest.group == "kde-frameworks"
        if !is_kde_added
          is_kde_added = true
          releases.push library
        end
      end
    end

    releases.sort! {|a,b| a.latest_manifest.release_date <=> b.latest_manifest.release_date}
    releases.reverse!

    return releases[0 .. 4]
  end

  def group name
    return @libraries.select do |l|
      manifest = l.latest_manifest
      manifest.group == name
    end
  end

  def library name
    @libraries.each do |library|
      if library.name == name
        return library
      end
    end
    nil
  end

  def manifest name
    @libraries.each do |library|
      if library.name == name
        return library.latest_manifest
      end
    end
    raise InqludeError.new("Unable to find manifest '#{name}'")
  end

  def topic name
    return @libraries.select do |l|
      manifest = l.latest_manifest
      if manifest.topics
        manifest.topics.include? name
      end
    end
  end

  def no_of_libraries topic
    count = 0
    @libraries.each do |l|
      topics = l.latest_manifest.topics
      if topics
        if l.latest_manifest.topics.include? topic
          count += 1
        end
      end
    end
    count
  end

  def read_remote
    @libraries.clear
    @manifests.clear

    if !@settings.offline
      fetch_remote
    end

    Dir.glob( "#{@settings.manifest_path}/*" ).sort.each do |dirname|
      next if !File.directory?( dirname )

      library = Library.new
      library.name = File.basename dirname
      local_manifests = Array.new
      Dir.glob( "#{dirname}/*.manifest" ).sort.each do |filename|
        manifest = Manifest.parse_file filename
        local_manifests.push manifest
        manifests.push manifest
      end
      library.manifests = local_manifests
      libraries.push library
    end
  end

  def fetch_remote
    if File.exists? @settings.manifest_path
      if !File.exists? @settings.manifest_path + "/.git"
        raise "Can't fetch data into '#{@settings.manifest_path}' because it's not a git repository."
      else
        system "cd #{@settings.manifest_path}; git pull >/dev/null"
      end
    else
      system "git clone git://anongit.kde.org/websites/inqlude-data " +
        "#{@settings.manifest_path}"
    end
  end

  def generate_inqlude_all
    all = []
    libraries.each do |l|
      all.push(l.latest_manifest.to_hash)
    end
    JSON.pretty_generate(all)
  end
end
