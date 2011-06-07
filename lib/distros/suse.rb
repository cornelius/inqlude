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

end
