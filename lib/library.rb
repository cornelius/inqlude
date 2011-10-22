class Library

  attr_accessor :name
  attr_accessor :manifests

  def versions
    versions = @manifests.map { |m| m["version"] }
  end
  
end
