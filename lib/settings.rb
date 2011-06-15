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

class Settings

  attr_accessor :offline

  def initialize
    @offline = false
  end

  def manifest_path
    local_path "manifests"
  end

  def cache_dir
    local_dir "cache"
  end

  def version
    Inqlude::VERSION
  end

  private

  def local_path dirname
    home = ENV["HOME"] + "/.inqlude/"
    Dir::mkdir home unless File.exists? home
    home + dirname
  end

  def local_dir dirname
    path = local_path dirname
    Dir::mkdir path unless File.exists? path
    path
  end

end
