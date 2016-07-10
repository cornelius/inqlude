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

class Verifier

  class Result
    attr_accessor :errors, :warnings, :name
    
    def initialize
      @valid = false
      @safe = false
      @errors = Array.new
      @warnings = Array.new
    end
    
    def valid?
      @errors.empty?
    end

    def has_warnings?
      !@warnings.empty?
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
      if has_warnings?
        @warnings.each do |warning|
          puts "  #{warning}"
        end
      end
    end
  end
  
  def initialize settings
    @settings = settings
  end

  def verify manifest
    @result = Result.new

    if !manifest.filename
      @result.errors.push "Unable to determine filename"
      @result.name = "<unknown>"
    else
      @result.name = manifest.filename
    end
    if !manifest.libraryname
      @result.errors.push "Unable to determine libraryname"
    end

    if @result.errors.empty?
      filename = manifest.filename
      
      if filename != manifest.expected_filename
        @result.errors.push "Expected file name: #{manifest.expected_filename}"
      end

      if manifest.release_date == "1970-01-01"
        @result.errors.push "Invalid release date: #{manifest.release_date}"
      end

      schema_name = manifest.schema_name
      schema_file = File.expand_path("../../schema/#{schema_name}", __FILE__)

      errors = JSON::Validator.fully_validate(schema_file, manifest.to_json)
      errors.each do |error|
        @result.errors.push "Schema validation error: #{error}"
      end

      topics =  manifest.topics
      if topics.nil?
        @result.warnings.push "Warning: missing `topics` attribute"
      else
        valid_topics = ["API", "Artwork", "Bindings", "Communication", "Data", "Desktop", "Development", "Graphics", 
          "Logging", "Mobile", "Multimedia", "Printing", "QML", "Scripting", "Security", "Text", "Web", "Widgets"]
        invalid_topics = topics - valid_topics
        if !invalid_topics.empty?
          @result.errors.push ("Invalid topics: " + invalid_topics*"," + ". Valid topics are " + valid_topics*",")
        end
      end
    end

    @result
  end

  def verify_file filename
    begin
      manifest = Manifest.parse_file filename
    rescue VerificationError => e
      @result = Result.new
      @result.name = filename
      @result.errors.push e
      return @result
    end

    verify manifest
  end

end
