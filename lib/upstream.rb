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

class Upstream

  def self.get_involved text, id = nil
    puts "You can help and get involved:"
    puts text
    if id
      puts "More info: https://github.com/cornelius/inqlude/issues/#{id}"
    end
  end

  def self.print_info
    puts
    puts "If you would like to help with development of the Inqlude tool,"
    puts "have a look at the git repository, in particular the list of open"
    puts "issues: https://github.com/cornelius/inqlude/issues"
    puts
    puts "If you would like to contribute information about a Qt based"
    puts "library, have a look at the git repository containing the library"
    puts "meta data: https://github.com/cornelius/inqlude_data"
    puts
    puts "Your help is appreciated."
    puts
    puts "If you have questions or comments, please let me know:"
    puts "Cornelius Schumacher <schumacher@kde.org>"
    puts
  end

end
