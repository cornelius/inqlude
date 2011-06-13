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

class Distro

  def self.detect
    distro_dir = File.join( File.dirname(__FILE__), "distros" )
    Dir.glob( "#{distro_dir}/*.rb" ).each do |distro_file|
      require distro_file
      class_name = File.basename(distro_file[0,distro_file.length-3]).capitalize
      distro = Kernel.const_get(class_name).new
      if distro.is_it_me?
        return distro
      end
    end

    nil
  end

end
