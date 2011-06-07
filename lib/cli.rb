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

    if options[:remote]
      handler.read_remote
      
      handler.manifests.each do |manifest|
        puts manifest["name"] + "-" + manifest["version"]
      end
    else
      get_involved "Add support for listing installed libraries"
    end
  end

  desc "view", "Create view"
  method_option :output_dir, :type => :string, :aliases => "-o",
    :desc => "Output directory", :required => true
  def view
    view = View.new ManifestHandler.new
    view.create options[:output_dir]
  end

end
