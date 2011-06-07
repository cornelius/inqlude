class Distro

  def self.detect
    distro_dir = File.join( File.dirname(__FILE__), "distros" )
    Dir.glob( "#{distro_dir}/*.rb" ).each do |distro_file|
      require distro_file
      class_name = File.basename(distro_file[0,distro_file.length-3]).capitalize
      distro = Kernel.const_get(class_name).new
      if distro.is_it_me?
        return distro
      end
    end

    nil
  end

end
