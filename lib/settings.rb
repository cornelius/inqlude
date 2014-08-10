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

  include XDG::BaseDir::Mixin

  def subdirectory
    "inqlude"
  end

  attr_accessor :offline, :manifest_path

  def initialize
    @offline = false
    @manifest_path = File.join(xdg_data_path.to_s, "manifests")
  end

  def data_path
    File.expand_path('../../data',__FILE__)
  end
  
  def cache_dir
    make_dir(File.join(xdg_cache_path.to_s))
  end

  def manifest_dir
    make_dir(@manifest_path)
  end

  def version
    Inqlude::VERSION
  end

  def xdg_data_path
    data.home
  end

  def xdg_cache_path
    cache.home
  end

  private

  def make_dir path
    FileUtils.mkdir_p(path)
    path
  end

end
