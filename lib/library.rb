class Library

  attr_accessor :name
  attr_accessor :manifests

  def versions
    versions = release_manifests.map { |m| m["version"] }
  end
  
  def generic_manifest
    @manifests.each do |m|
      if m["schema_type"] == "generic"
        return m
      end
    end
    nil
  end

  def release_manifests
    result = @manifests.reject { |m| m["schema_type"] == "generic" }
    result.sort! do |m1,m2|
      m1["release_date"] <=> m2["release_date"]
    end
    result
  end
  
  def latest_manifest
    if release_manifests.empty?
      return generic_manifest
    else
      return release_manifests.last
    end
  end

end
