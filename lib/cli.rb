class Cli < Thor

  default_task :global

  class_option :version, :type => :boolean, :desc => "Show version"

  def self.distro= d
    @@distro = d
  end

  desc "global", "Global options", :hide => true
  def global
    if options[:version]
      puts "Inqlude: #{$version}"

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
    handler = ManifestHandler.new
    handler.read_remote

    if options[:remote]
      handler.manifests.each do |manifest|
        puts manifest["name"] + "-" + manifest["version"]
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
  def view
    view = View.new ManifestHandler.new
    view.create options[:output_dir]
  end

  desc "show <library_name>", "Show library details"
  def show name
    get_involved "Add command for showing library details"
  end

  desc "verify", "Verify manifests"
  def verify
    get_involved "Add command for verifying manifests"
  end

end
