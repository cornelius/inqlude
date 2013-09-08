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

class Cli < Thor

  default_task :global

  class_option :version, :type => :boolean, :desc => "Show version"
  class_option :offline, :type => :boolean, :desc => "Work offline"

  def self.settings= s
    @@settings = s
  end

  def self.distro= d
    @@distro = d
  end

  desc "global", "Global options", :hide => true
  def global
    if options[:version]
      puts "Inqlude: #{@@settings.version}"

      qmake_out = `qmake -v`
      qmake_out =~ /Qt version (.*) in/
      puts "Qt: #{$1}"

      if @@distro
        puts "OS: #{@@distro.name} #{@@distro.version}"
      else
        puts "OS: unknown"
      end
    else
      Cli.help shell
    end
  end

  desc "list", "List libraries"
  method_option :remote, :type => :boolean, :aliases => "-r",
    :desc => "List remote libraries"
  def list
    process_global_options options

    handler = ManifestHandler.new @@settings
    handler.read_remote

    if options[:remote]
      handler.libraries.each do |library|
        puts library.name + " (" + library.versions.join(", ") + ")"
      end
    else
      manifests = @@distro.installed handler
      manifests.each do |manifest|
        puts manifest["name"]
      end
    end
  end

  desc "view", "Create view"
  method_option :output_dir, :type => :string, :aliases => "-o",
    :desc => "Output directory", :required => true
  method_option :enable_disqus, :type => :boolean,
    :desc => "Enable Disqus based comments on generate web pages. Works only on
actual domain."
  method_option :disable_search, :type => :boolean,
    :desc => "Disable Google based search."
  def view
    process_global_options options
  
    view = View.new ManifestHandler.new @@settings
    view.enable_disqus = options[:enable_disqus]
    view.enable_search = !options[:disable_search]
    view.create options[:output_dir]
  end

  desc "show <library_name>", "Show library details"
  def show name
    Upstream.get_involved "Add command for showing library details", 1
  end

  desc "verify", "Verify manifests"
  def verify
    process_global_options options

    v = Verifier.new @@settings

    handler = ManifestHandler.new @@settings
    handler.read_remote
    count_ok = 0
    count_error = 0
    handler.libraries.each do |library|
      library.manifests.each do |manifest|
        if v.verify manifest
          count_ok += 1
        else
          count_error += 1
        end
      end
    end
    puts "#{handler.manifests.count} manifests checked. #{count_ok} ok, " +
      "#{count_error} with error."
  end

  desc "system_scan", "Scan system for installed Qt libraries and create manifests"
  method_option :dry_run, :type => :boolean,
    :desc => "Dry run. Don't write files."
  method_option :recreate_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of installed RPMs"
  method_option :recreate_qt_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of Qt library RPMs"
  def system_scan
    m = RpmManifestizer.new @@settings
    m.dry_run = options[:dry_run]

    if options[:recreate_source_cache]
      m.create_source_cache
    end
    
    if options[:recreate_qt_source_cache]
      m.create_qt_source_cache
    end
    
    m.process_all_rpms
  end

  desc "get_involved", "Information about how to get involved"
  def get_involved
    Upstream.print_info
  end

  desc "uninstall", "Uninstall library"
  def uninstall name
    handler = ManifestHandler.new @@settings
    manifest = handler.manifest name
    if !manifest
      STDERR.puts "Manifest for '#{name}' not found"
    else
      @@distro.uninstall manifest
    end
  end

  desc "install", "Install library"
  method_option :dry_run, :type => :boolean,
    :desc => "Only show what would happen, don't install anything."
  def install name
    handler = ManifestHandler.new @@settings
    manifest = handler.manifest name
    if !manifest
      STDERR.puts "Manifest for '#{name}' not found"
    else
      @@distro.install manifest, :dry_run => options[:dry_run]
    end
  end

  private
  
  def process_global_options options
    @@settings.offline = options[:offline]
  end

end
