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
  
  def self.parse_schema_id schema_id
    schema_id =~ /^http:\/\/inqlude\.org\/schema\/(.*)-manifest-v(.*)\#$/
    type = $1
    version = $2.to_i
    raise "Unable to parse schema id '{schema_id}'" if !type || !version
    return type, version
  end

end
