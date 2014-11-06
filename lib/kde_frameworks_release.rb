# Copyright (C) 2014 Cornelius Schumacher <schumacher@kde.org>
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

class KdeFrameworksRelease
  
  attr_reader :generic_manifests
  
  def initialize handler
    @handler = handler
  end
  
  def self.strip_patch_release(version)
    version =~ /^(\d+\.\d+)\./
    $1
  end

  def self.create_release_manifest generic_manifest, release_date, version
    m = generic_manifest.create_release_manifest(release_date, version)

    version_dir = strip_patch_release(version)

    download_url = "http://download.kde.org/stable/frameworks/#{version_dir}/"
    m.urls.download = download_url
    m.maturity = "stable"
    m.packages.source = "#{download_url}#{m.name}-#{version}.tar.xz"
    m
  end

  def read_generic_manifests
    @generic_manifests = Array.new
    @handler.read_remote
    @handler.group("kde-frameworks").each do |library|
      @generic_manifests.push library.generic_manifest
    end
    @generic_manifests
  end

  def write_release_manifests release_date, version
    @generic_manifests.each do |generic_manifest|
      release_manifest = KdeFrameworksRelease.create_release_manifest(
        generic_manifest, release_date, version )
      path = @handler.manifest_path( release_manifest )
      File.open( path, "w" ) do |file|
        file.write release_manifest.to_json
      end
    end    
  end
  
end
