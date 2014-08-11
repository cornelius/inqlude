class Manifest

  def self.generic_schema_id
    "http://inqlude.org/schema/generic-manifest-v1#"
  end

  def self.release_schema_id
    "http://inqlude.org/schema/release-manifest-v1#"
  end

  def self.proprietary_release_schema_id
    "http://inqlude.org/schema/proprietary-release-manifest-v1#"
  end

  def self.parse_file path
    manifest = JSON File.read path
    filename = File.basename path
    manifest["filename"] = filename
    filename =~ /^(.*?)\./
    manifest["libraryname"] = $1
    manifest["schema_type"],manifest["schema_version"] =
      Manifest.parse_schema_id manifest["$schema"]
    manifest
  end
  
  def self.to_json manifest
    m = manifest.clone
    m.delete "filename"
    m.delete "libraryname"
    m.delete "schema_type"
    m.delete "schema_version"
    JSON.pretty_generate m
  end
  
  def self.parse_schema_id schema_id
    schema_id =~ /^http:\/\/inqlude\.org\/schema\/(.*)-manifest-v(.*)\#$/
    type = $1
    version = $2.to_i
    raise "Unable to parse schema id '{schema_id}'" if !type || !version
    return type, version
  end

  class Packages
    attr_accessor :source
  end

  class Urls
    attr_accessor :homepage, :api_docs, :download, :tutorial, :vcs,
      :description_source, :announcement
  end

  attr_accessor :name, :version, :summary, :description, :maturity
  attr_accessor :release_date
  attr_accessor :urls, :packages
  attr_accessor :licenses, :authors, :platforms

  attr_accessor :schema_type, :schema_version

  def initialize(schema_id)
    @schema_type, @schema_version = Manifest.parse_schema_id(schema_id)
    @packages = Packages.new
    @urls = Urls.new
  end

end

class ManifestGeneric < Manifest
  def initialize
    super(Manifest.generic_schema_id)
  end
end

class ManifestProprietaryRelease < Manifest
  def initialize
    super(Manifest.proprietary_release_schema_id)
  end
end

class ManifestRelease < Manifest
  def initialize
    super(Manifest.release_schema_id)
  end
end
