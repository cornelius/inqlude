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

  def self.for_schema_id schema_id
    if schema_id == generic_schema_id
      return ManifestGeneric.new
    elsif schema_id == release_schema_id
      return ManifestRelease.new
    elsif schema_id == proprietary_release_schema_id
      return ManifestProprietaryRelease.new
    else
      raise VerificationError.new("Unknown schema id '#{schema_id}'")
    end
  end

  def self.parse_file path
    json = JSON File.read path
    manifest = Manifest.for_schema_id(json["$schema"])
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
  
  def to_json
    hash = Hash.new
    hash["$schema"] = schema_id
    hash["name"] = name
    hash["display_name"] = display_name if display_name
    hash["release_date"] = release_date if release_date
    hash["version"] = version if version
    hash["summary"] = summary
    hash["urls"] = urls.to_hash
    hash["licenses"] = licenses
    hash["description"] = description
    hash["authors"] = authors if authors
    hash["maturity"] = maturity if maturity
    hash["platforms"] = platforms
    hash["packages"] = packages.to_hash if packages.source
    hash["group"] = group if group
    JSON.pretty_generate hash
  end
  
  def self.parse_schema_version schema_id
    schema_id =~ /^http:\/\/inqlude\.org\/schema\/(.*)-manifest-v(.*)\#$/
    type = $1
    version = $2.to_i
    raise "Unable to parse schema id '{schema_id}'" if !type || !version
    return version
  end

  class Packages
    attr_accessor :source, :openSUSE

    def to_hash
      hash = { "source" => source }
      hash["openSUSE"] = openSUSE if openSUSE
      hash
    end
  end

  class Urls
    attr_accessor :homepage, :api_docs, :download, :tutorial, :vcs,
      :description_source, :announcement, :mailing_list, :contact
    attr_accessor :custom

    def keys
      ["homepage", "api_docs", "download", "tutorial", "vcs",
       "description_source", "announcement", "mailing_list", "contact",
       "custom"]
    end

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
      h["contact"] = contact if contact
      h["custom"] = custom if custom
      h
    end
  end

  attr_accessor :name, :version, :summary, :description, :maturity, :group,
    :display_name
  attr_accessor :release_date
  attr_accessor :urls, :packages
  attr_accessor :licenses, :authors, :platforms

  attr_reader :schema_version
  attr_reader :schema_id

  attr_accessor :filename, :libraryname

  def initialize(schema_id)
    @schema_id = schema_id
    @schema_version = Manifest.parse_schema_version(schema_id)
    @packages = Packages.new
    @urls = Urls.new
    @licenses = Array.new
  end

  def schema_name
    regexp = /Manifest([A-Z][a-z]*)([A-Z][a-z]*)?/
    match = regexp.match(self.class.to_s)
    if !match
      raise "Class '#{self.class} is not a Manifest sub class"
    end
    schema_type = match[1].downcase
    if match[2]
      schema_type += "-" + match[2].downcase
    end
    "#{schema_type}-manifest-v#{schema_version}"
  end

  def path
    File.join( name, expected_filename )
  end
end

class ManifestGeneric < Manifest
  def initialize
    super(Manifest.generic_schema_id)
  end

  def expected_filename
    "#{name}.manifest"
  end

  def is_released?
    if licenses == ["Commercial"]
      return true
    else
      return false
    end
  end

  def has_version?
    false
  end
end

class ManifestRelease < Manifest
  def initialize
    super(Manifest.release_schema_id)
  end

  def expected_filename
    "#{name}.#{release_date}.manifest"
  end

  def is_released?
    return true
  end

  def has_version?
    true
  end
end

class ManifestProprietaryRelease < Manifest
  def initialize
    super(Manifest.proprietary_release_schema_id)
  end

  def expected_filename
    "#{name}.#{release_date}.manifest"
  end

  def is_released?
    return true
  end

  def has_version?
    true
  end
end

