class Manifest < JsonObject

  def self.descendants
    ObjectSpace.each_object(::Class).select { |klass| klass < self }
  end

  def self.for_schema_id schema_id
    descendants.each do |manifest_class|
      if schema_id == manifest_class.schema_id
        return manifest_class.new
      end
    end
    raise VerificationError.new("Unknown schema id '#{schema_id}'")
  end

  def self.parse_file path
    json = JSON File.read path
    manifest = Manifest.for_schema_id(json["$schema"])
    manifest.filename = File.basename path
    manifest.filename =~ /^(.*?)\./
    manifest.libraryname = $1

    manifest.from_hash(json)
  end
  
  def self.parse_schema_version schema_id
    schema_id =~ /^http:\/\/inqlude\.org\/schema\/(.*)-manifest-v(.*)\#$/
    type = $1
    version = $2.to_i
    raise "Unable to parse schema id '{schema_id}'" if !type || !version
    return version
  end

  attribute :name
  attribute :display_name
  attribute :release_date
  attribute :version
  attribute :summary
  attribute :urls do
    attribute :homepage
    attribute :api_docs
    attribute :download
    attribute :tutorial
    attribute :vcs
    attribute :description_source
    attribute :announcement
    attribute :mailing_list
    attribute :contact
    attribute :custom
  end
  attribute :licenses
  attribute :description
  attribute :authors
  attribute :maturity
  attribute :platforms
  attribute :packages do
    attribute :source
    attribute :openSUSE
  end
  attribute :group

  attr_reader :schema_version

  attr_accessor :filename, :libraryname

  def initialize(schema_id)
    @schema_id = schema_id
    @schema_version = Manifest.parse_schema_version(schema_id)
    super()
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
  def self.schema_id
    "http://inqlude.org/schema/generic-manifest-v1#"
  end

  def initialize
    super(ManifestGeneric.schema_id)
  end

  def expected_filename
    "#{name}.manifest"
  end

  def is_released?
    # Purely commercial libraries often don't have release information publicly
    # available, so we treat them as released, even, if the manifest only has
    # generic data.
    if licenses == ["Commercial"]
      return true
    else
      return false
    end
  end

  def has_version?
    false
  end

  def create_release_manifest(release_date, version)
    m = ManifestRelease.new
    ManifestGeneric.all_keys.each do |key, type|
      value = send("#{key}")
      if value
        m.send("#{key}=", value)
      end
    end

    m.release_date = release_date
    m.version = version
    m
  end
end

class ManifestRelease < Manifest
  def self.schema_id
    "http://inqlude.org/schema/release-manifest-v1#"
  end

  def initialize
    super(ManifestRelease.schema_id)
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
  def self.schema_id
    "http://inqlude.org/schema/proprietary-release-manifest-v1#"
  end

  def initialize
    super(ManifestProprietaryRelease.schema_id)
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

