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

  class Result
    attr_accessor :valid, :errors, :name
    
    def initialize
      @valid = false
      @errors = Array.new
    end
    
    def valid?
      @valid
    end

    def print_result
      print "Verify manifest #{@name}..."
      if valid?
        puts "ok"
      else
        puts "error"
        @errors.each do |error|
          puts "  #{error}"
        end
      end
    end
  end
  
  def initialize settings
    @settings = settings

    @allowed_keys = [ "schema_version", "name", "version", "release_date",
      "summary", "urls", "licenses", "description", "authors", "maturity",
      "platforms", "packages", "keywords", "dependencies", "filename",
      "libraryname", "display_name" ]
    @mandatory_keys = [ "schema_version", "name", "version", "release_date",
      "summary", "urls", "licenses", "description", "maturity",
      "platforms", "packages" ]
  end

  def verify manifest
    @result = Result.new

    if !manifest["filename"]
      @result.errors.push "Unable to determine filename"
      @result.name = "<unknown>"
    else
      @result.name = manifest["filename"]
    end
    if !manifest["libraryname"]
      @result.errors.push "Unable to determine libraryname"
    end

    if @result.errors.empty?
      filename = manifest["filename"]
      expected_filename = "#{manifest["libraryname"]}.#{manifest["release_date"]}.manifest"

      if filename != expected_filename
        @result.errors.push "Expected file name: #{expected_filename}"
      end

      if manifest["release_date"] == "1970-01-01"
        @result.errors.push "Invalid release date: #{manifest["release_date"]}"
      end

      manifest.keys.each do |key|
        if !@allowed_keys.include? key
          @result.errors.push "Illegal entry: #{key}"
        end
      end

      schema_name = File.expand_path('../../schema/inqlude-schema.json', 
                                     __FILE__)

      errors = JSON::Validator.fully_validate(schema_name, manifest)
      errors.each do |error|
        @result.errors.push "Schema validation error: #{error}"
      end
    end
    
    if @result.errors.empty?
      @result.valid = true
      return @result
    else
      @result.valid = false
      return @result
    end
  end

  def verify_file filename
    manifest = JSON File.read filename
    manifest["filename"] = filename
    filename =~ /^(.*?)\./
    manifest["libraryname"] = $1
    verify manifest
  end

end
