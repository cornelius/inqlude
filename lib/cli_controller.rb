class CliController
  def self.print_versions(distro)
    puts "Inqlude: #{Inqlude::VERSION}"

    if find_executable("qmake")
      qmake_out = `qmake -v`
      qmake_out =~ /Qt version (.*) in/
      puts "Qt: #{$1}"
    else
      puts "Qt: not found"
    end

    if distro
      puts "OS: #{distro.name} #{distro.version}"
    else
      puts "OS: unknown"
    end
  end

  def self.find_executable(executable)
    `which #{executable}`
    $?.success?
  end
end
