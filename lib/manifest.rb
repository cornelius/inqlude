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
    json = JSON File.read path
    manifest = Manifest.new(json["$schema"])
    manifest.filename = File.basename path
    manifest.filename =~ /^(.*?)\./
    manifest.libraryname = $1

    manifest.name = json["name"]
    manifest.display_name = json["display_name"]
    manifest.release_date = json["release_date"]
    manifest.version = json["version"]
    manifest.summary = json["summary"]
    json["urls"].each do |key,value|
      manifest.urls.send(key + "=",value)
    end
    manifest.licenses = json["licenses"]
    manifest.description = json["description"]
    manifest.authors = json["authors"]
    manifest.maturity = json["maturity"]
    manifest.platforms = json["platforms"]
    if json["packages"]
      json["packages"].each do |key,value|
        manifest.packages.send(key + "=", value)
      end
    end
    manifest.group = json["group"]

    manifest
  end
  
  def self.to_json manifest
    hash = Hash.new
    hash["$schema"] = manifest.schema_id
    hash["name"] = manifest.name
    hash["display_name"] = manifest.display_name if manifest.display_name
    hash["release_date"] = manifest.release_date if manifest.release_date
    hash["version"] = manifest.version if manifest.version
    hash["summary"] = manifest.summary
    hash["urls"] = manifest.urls.to_hash
    hash["licenses"] = manifest.licenses
    hash["description"] = manifest.description
    hash["authors"] = manifest.authors
    hash["maturity"] = manifest.maturity if manifest.maturity
    hash["platforms"] = manifest.platforms
    hash["packages"] = manifest.packages.to_hash if manifest.packages.source
    hash["group"] = manifest.group if manifest.group
    JSON.pretty_generate hash
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

    def to_hash
      { "source" => source }
    end
  end

  class Urls
    attr_accessor :homepage, :api_docs, :download, :tutorial, :vcs,
      :description_source, :announcement, :mailing_list

    def to_hash
      h = Hash.new
      h["homepage"] = homepage if homepage
      h["api_docs"] = api_docs if api_docs
      h["download"] = download if download
      h["tutorial"] = tutorial if tutorial
      h["vcs"] = vcs if vcs
      h["description_source"] = description_source if description_source
      h["announcement"] = announcement if announcement
      h["mailing_list"] = mailing_list if mailing_list
      h
    end
  end

  attr_accessor :name, :version, :summary, :description, :maturity, :group,
    :display_name
  attr_accessor :release_date
  attr_accessor :urls, :packages
  attr_accessor :licenses, :authors, :platforms

  attr_reader :schema_type, :schema_version
  attr_reader :schema_id

  attr_accessor :filename, :libraryname

  def initialize(schema_id)
    @schema_id = schema_id
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
