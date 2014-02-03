class Library

  attr_accessor :name
  attr_accessor :manifests

  def versions
    versions = @manifests.map { |m| m["version"] }
  end
  
  def generic_manifest
    @manifests.each do |m|
      if m["schema_type"] == "generic"
        return m
      end
    end
    nil
  end
  
end
