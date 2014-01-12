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

class KdeFrameworksCreator

  attr_reader :warnings, :errors
  
  def initialize
    @frameworks = Hash.new
  end
  
  def parse_checkout dir_name, options = {}
    @warnings = []
    @errors = []
    Dir.entries( dir_name ).each do |entry|
      next if entry =~ /^\./
      next if entry == "kapidox"
      next if entry == "kde4support"
      
      @frameworks[entry] = {}
      parse_readme File.join(dir_name,entry), options
      parse_authors File.join(dir_name,entry)
    end
  end

  def frameworks
    @frameworks.keys
  end
  
  def framework name
    f = @frameworks[name]
    raise "Unable to read '#{name}'" if !f
    f
  end
  
  def parse_readme path, options = {}
    @errors = [] if !@errors
    
    name = extract_name( path )
    framework = @frameworks[name] || {}

    state = nil
    File.open(File.join(path,"README.md")).each_line do |line|
      if line =~ /^# (.*)/
        framework["title"] = $1
        state = :parse_summary
        next
      elsif line =~ /^## Introduction/
        framework["introduction"] = "" 
        state = :parse_introduction
        next
      elsif line =~ /^## Links/
        state = :parse_links
        next
      end

      if state == :parse_summary
        if line =~ /^##/
          state = nil
        else
          if !line.strip.empty?
            framework["summary"] = line.strip
          end
        end
      end
      
      if state == :parse_introduction
        if line =~ /^##/
          framework["introduction"].strip!
          state = nil
        else
          framework["introduction"] += line
        end
      end
      
      if state == :parse_links
        if line =~ /^##/
          state = nil
        else
          if line =~ /- (.*): (.*)/
            link_name = $1
            url = $2
            link_name = link_name.downcase.gsub(/ /,"_")
            if url =~ /<(.*)>/
              url = $1
            end
            framework["link_#{link_name}"] = url
          end
        end
      end
    end
    
    required_fields = []
    [ "title", "summary", "introduction", "link_home_page" ].each do |field|
      if !options[:ignore_errors] || !options[:ignore_errors].include?(field)
        required_fields.push field
      end
    end
    
    required_fields.each do |field|
      if !framework.has_key?(field) || framework[field].strip.empty?
        @errors.push( { :name => name, :issue => "missing_" + field } )
      end
    end

    @frameworks[name] = framework
  end
  
  def parse_authors path
    name = extract_name( path )

    authors_path = File.join(path,"AUTHORS")
    if ( !File.exists?( authors_path ) )
      @warnings.push( { :name => name, :issue => "missing_file",
                       :details => "AUTHORS" } )
      return
    end
    
    authors = []
    File.open(authors_path).each_line do |line|
      if line =~ /(.* <.*@.*>)/
        authors.push $1
      end
    end

    framework = @frameworks[name] || {}

    framework["authors"] = authors
    
    @frameworks[name] = framework
  end

  def extract_name path
    path.split("/").last
  end
  
  def create_manifests output_dir
    settings = Settings.new
    settings.manifest_path = output_dir
    @frameworks.each do |name,framework|
      creator = Creator.new settings, name
      manifest = creator.create_generic_manifest
      fill_in_data framework, manifest
      creator.create_dir
      creator.write_manifest manifest
    end
  end
  
  def fill_in_data framework, manifest
    manifest["display_name"] = framework["title"]
    manifest["summary"] = framework["summary"]
    manifest["description"] = framework["introduction"]
    manifest["urls"]["vcs"] = framework["link_git_repository"]
    manifest["urls"]["homepage"] = framework["link_home_page"]
    manifest["urls"]["mailing_list"] = framework["link_mailing_list"]
    manifest["licenses"] = [ "LGPLv2.1+" ]
    manifest["authors"] = [ "The KDE Community" ]
    manifest["group"] = "kde-frameworks"
  end
end
