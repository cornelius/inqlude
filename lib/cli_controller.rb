class CliController
  def self.print_versions(distro)
    puts "Inqlude: #{Inqlude::VERSION}"

    qmake_out = `qmake -v`
    qmake_out =~ /Qt version (.*) in/
    puts "Qt: #{$1}"

    if distro
      puts "OS: #{distro.name} #{distro.version}"
    else
      puts "OS: unknown"
    end
  end 
end
