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
  class_option :manifest_dir, :type => :string, :desc => "Manifest directory"

  def self.settings= s
    @@settings = s
  end

  def self.distro
    @@distro if @@distro

    @@distro = Distro.detect
    if !@@distro
      STDERR.puts "Warning: unable to detect distro."
    end
  end

  desc "global", "Global options", :hide => true
  def global
    if options[:version]
      puts "Inqlude: #{@@settings.version}"

      qmake_out = `qmake -v`
      qmake_out =~ /Qt version (.*) in/
      puts "Qt: #{$1}"

      if self.distro
        puts "OS: #{self.distro.name} #{self.distro.version}"
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
      manifests = self.distro.installed handler
      manifests.each do |manifest|
        puts manifest["name"]
      end
    end
  end

  desc "view", "Create view"
  method_option :output_dir, :type => :string, :aliases => "-o",
    :desc => "Output directory", :required => true
  method_option :manifest_dir, :type => :string, :aliases => "-m",
    :desc => "Manifest directory", :required => false
  method_option :enable_disqus, :type => :boolean,
    :desc => "Enable Disqus based comments on generate web pages. Works only on
actual domain."
  method_option :disable_search, :type => :boolean,
    :desc => "Disable Google based search."
  def view
    process_global_options options

    if options[:manifest_dir]
      @@settings.manifest_path = options[:manifest_dir]
    end

    manifest_handler = ManifestHandler.new(@@settings)
    manifest_handler.read_remote

    view = View.new(manifest_handler)
    view.enable_disqus = options[:enable_disqus]
    view.enable_search = !options[:disable_search]
    view.create options[:output_dir]
  end

  desc "show <library_name>", "Show library details"
  def show name
    Upstream.get_involved "Add command for showing library details", 1
  end

  desc "verify [filename]", "Verify all manifests or specific file if filename is given"
  method_option :check_links, :type => :boolean,
    :desc => "Check links for reachability."
  def verify filename=nil
    process_global_options options

    v = Verifier.new @@settings

    if options[:check_links]
      Upstream.get_involved "Implement --check-links option", 11
      exit 1
    end

    errors = []

    if filename
      result = v.verify_file filename
      result.print_result
    else
      handler = ManifestHandler.new @@settings
      handler.read_remote
      count_ok = 0
      count_warning = 0
      handler.libraries.each do |library|
        library.manifests.each do |manifest|
          result = v.verify manifest
          result.print_result
          if result.valid? && result.safe?
            count_ok += 1
          elsif !result.valid?
            errors.push result
          end
          if !result.safe?
            count_warning +=1
          end
        end
      end
      puts
      if(count_warning == 1)
        puts "#{handler.manifests.count} manifests checked. #{count_ok} ok, " +
          "#{errors.count} with error, " +
          "#{count_warning} warning."
      else
        puts "#{handler.manifests.count} manifests checked. #{count_ok} ok, " +
          "#{errors.count} with error, " +
          "#{count_warning} warnings."
      end
      if !errors.empty?
        puts
        puts "Errors:"
        errors.each do |error|
          puts "  #{error.name}"
          error.errors.each do |e|
            puts "    #{e}"
          end
        end

        exit 1
      end
    end
  end

  desc "review <repo>", "Review pull requests on GitHub. Use 'username:branch' as repo parameter."
  def review repo, action = nil
    if !action
      GitHubTool.review repo
    elsif action == "accept"
      GitHubTool.accept repo
    else
      STDERR.puts "Unknown review action: '#{action}'"
      exit 1
    end
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

  desc "create <manifest_name> [version] [release_date]", "Create new or updated manifest"
  method_option :kf5, :type => :boolean,
    :desc => "Create KDE Framworks 5 template", :required => false
  def create name, version=nil, release_date=nil
    @@settings.manifest_path = "."
    creator = Creator.new @@settings, name
    if creator.is_new?
      if !version && release_date || version && !release_date
        STDERR.puts "You need to specify both, version and release date"
        exit 1
      end
      if version && release_date
        if options[:kf5]
          creator.create_kf5 version, release_date
        else
          creator.create version, release_date
        end
      else
        creator.create_generic
      end
    else
      if !version || !release_date
        STDERR.puts "Updating manifest requires version and release_date"
        exit 1
      end
      creator.validate_directory
      creator.update version, release_date
    end
  end

  desc "create_kde_frameworks <frameworks-git-checkout> <output_dir>",
    "Create manifests from git checkout of KDE frameworks module in given directory"
  method_option "show-warnings", :type => :boolean,
    :desc => "Show warnings about missing data", :required => false
  method_option "ignore-errors-homepage", :type => :boolean,
    :desc => "Ignore errors about missing home page", :required => false
  def create_kde_frameworks checkout_dir, output_dir
    k = KdeFrameworksCreator.new
    if options["ignore-errors-homepage"]
      k.parse_checkout checkout_dir, :ignore_errors => [ "link_home_page" ]
    else
      k.parse_checkout checkout_dir
    end
    k.create_manifests output_dir
    k.errors.each do |error|
      puts "#{error[:name]}: #{error[:issue]}"
    end
    if options["show-warnings"]
      k.warnings.each do |warning|
        puts "#{warning[:name]}: #{warning[:issue]} (#{warning[:details]})"
      end
    end
  end

  desc "release_kde_frameworks <release_date> <version>",
    "Create release manifests for KDE frameworks release"
  def release_kde_frameworks release_date, version
    process_global_options options

    handler = ManifestHandler.new @@settings
    k = KdeFrameworksRelease.new handler
    k.read_generic_manifests
    k.write_release_manifests release_date, version
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
      self.distro.uninstall manifest
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
      self.distro.install manifest, :dry_run => options[:dry_run]
    end
  end

  desc "download", "Download source code archive"
  def download(name)
    handler = ManifestHandler.new(@@settings)
    handler.read_remote
    manifest = handler.manifest(name)
    if !manifest
      STDERR.outs "Manifest for '#{name}' not found"
      exit 1
    else
      Downloader.new(handler, STDOUT).download(name, Dir.pwd)
    end
  end

  private

  def process_global_options options
    @@settings.offline = options[:offline]
    if options[:manifest_dir]
      @@settings.manifest_path = options[:manifest_dir]
    end
  end

end
