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

class Verifier

  def initialize settings
    @settings = settings

    @allowed_keys = [ "schema_version", "name", "version", "release_date",
      "summary", "urls", "licenses", "description", "authors", "maturity",
      "platforms", "packages", "keywords", "dependencies" ]
  end

  def verify manifest
    @errors = Array.new
    
    print "Verify manifest #{manifest[:name]}..."

    manifest.keys.each do |key|
      if !@allowed_keys.include? key
        @errors.push "Illegal entry: #{key}"
      end
    end
    
    if @errors.empty?
      puts "ok"
    else
      puts "error"
      @errors.each do |error|
        puts "  #{error}"
      end
    end
  end
  
end
