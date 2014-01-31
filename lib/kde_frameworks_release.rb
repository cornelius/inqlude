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
  
  def create_release_manifest generic_manifest, date, version
    m = generic_manifest
    name = m["name"]
    download_url = "ftp://ftp.kde.org/pub/kde/stable/#{name}/"
    m["$schema"] = Manifest.release_schema_id
    m["urls"]["download"] = download_url
    m["maturity"] = "alpha"
    m["release_date"] = date
    m["version"] = version
    m["packages"] = {
      "source" => "#{download_url}#{name}-#{version}.tar.bz2"
    }
    m
  end

end
