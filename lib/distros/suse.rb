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

class Suse

  attr_accessor :name, :version

  def is_it_me?
    begin
      File.open "/etc/SuSE-release" do |file|
        if file.readline =~ /^openSUSE/
          @name = "openSUSE"
          file.readline =~ /VERSION = (.*)/
          @version = $1
        end
      end
      
      true
    rescue Errno::ENOENT
      false
    end
  end

  def installed handler
    packages = Hash.new

    `rpmqpack`.each_line do |package|
      packages[package.chomp] = true
    end

    unknown = 0

    installed = Array.new
    handler.manifests.each do |manifest|
      unknown += 1
      package_section = manifest["packages"]
      next unless package_section
      name_section = package_section[name]
      next unless name_section
      version_section = name_section[version]
      next unless version_section
      if packages.has_key? version_section["package_name"]
        installed.push manifest
        unknown -= 1
      end
    end

    if unknown > 0
      STDERR.puts "Warning: #{unknown} libraries don't have package information"
    end  
  
    installed
  end

  def uninstall manifest
    package_name = get_package_name manifest
    if package_name
      system "sudo zypper rm #{package_name}"
    end
  end

  def install manifest, options = {}
    package_name = get_package_name manifest
    cmd_options = Array.new
    if options[:dry_run]
      cmd_options.push "--dry-run"
    end
    if package_name
      system "sudo zypper install #{cmd_options.join(" ")} #{package_name}"
    end
  end

  def get_package_name manifest
    package_section = manifest["packages"]
    if !package_section
      STDERR.puts "No packages section in metadata"
    else
      name_section = package_section[name]
      if !name_section
        STDERR.puts "No section '#{name}' found in packages section."
      else
        version_section = name_section[version]
        if !version_section
          STDERR.puts "No section '#{version}' found in section '#{name}'"
        else
          package_name = version_section["package_name"]
          if !package_name || package_name.empty?
            STDERR.puts "No package name found"
          else
            return package_name
          end
        end
      end
    end
    nil
  end

end
