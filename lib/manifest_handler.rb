class ManifestHandler

  attr_reader :manifests
  
  def initialize
    @manifests = Array.new
  end

  def read_remote
    Dir.glob( "#{$manifest_dir}/*.manifest" ).sort.each do |filename|
      File.open filename do |file|
        manifests.push JSON file.read
      end
    end
  end

end
