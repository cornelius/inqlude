require File.expand_path('../spec_helper', __FILE__)

describe Manifest do

  include_context "manifest_files"
  
  it "provides schema identifier" do
    expect(ManifestRelease.schema_id).to include("inqlude.org")
    expect(ManifestRelease.schema_id).to include("release")

    expect(ManifestGeneric.schema_id).to include("inqlude.org")
    expect(ManifestGeneric.schema_id).to include("generic")

    expect(ManifestProprietaryRelease.schema_id).to include("inqlude.org")
    expect(ManifestProprietaryRelease.schema_id).to include("proprietary")
  end

  it "returns schema id" do
    expect(ManifestGeneric.schema_id).to eq(
      "http://inqlude.org/schema/generic-manifest-v1#")
    expect(ManifestRelease.schema_id).to eq(
      "http://inqlude.org/schema/release-manifest-v1#")
    expect(ManifestProprietaryRelease.schema_id).to eq(
      "http://inqlude.org/schema/proprietary-release-manifest-v1#")
  end
  
  it "parses schema version" do
    expect{Manifest.parse_schema_version("xxx")}.to raise_error StandardError

    version = Manifest.parse_schema_version(
      "http://inqlude.org/schema/release-manifest-v1#" )
    expect(version).to eq 1

    version = Manifest.parse_schema_version(
      "http://inqlude.org/schema/release-manifest-v2#" )
    expect(version).to eq 2

    version = Manifest.parse_schema_version(
      "http://inqlude.org/schema/generic-manifest-v1#" )
    expect(version).to eq 1
  end
  
  it "parses release manifest" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    manifest = Manifest.parse_file filename
    expect(manifest.class).to be ManifestRelease
    expect(manifest.name).to eq "awesomelib"
    expect(manifest.version).to eq "0.2.0"

    expect(manifest.filename).to eq "awesomelib.2013-09-08.manifest"
    expect(manifest.libraryname).to eq "awesomelib"

    expect(manifest.schema_version).to eq 1
  end

  it "parses generic manifest" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    manifest = Manifest.parse_file filename
    expect(manifest.class).to be ManifestGeneric
    expect(manifest.name).to eq "newlib"
    expect(manifest.version).to eq nil

    expect(manifest.filename).to eq "newlib.manifest"

    expect(manifest.schema_version).to eq 1
  end

  it "writes JSON for release manifest" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    manifest = Manifest.parse_file filename
    expect( manifest.to_json ).to eq File.read( filename )
  end

  it "writes JSON for generic manifest" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    manifest = Manifest.parse_file filename
    expect( manifest.to_json ).to eq File.read( filename )
  end

  it "has accessors for all attributes" do
    m = ManifestRelease.new

    m.name = "Name"
    expect(m.name).to eq "Name"

    m.release_date = Date.parse("2014-08-11")
    expect(m.release_date).to eq Date.parse("2014-08-11")
    expect(m.release_date.to_s).to eq "2014-08-11"

    m.version = "0.7.0"
    expect(m.version).to eq "0.7.0"

    m.summary = "One-line summary"
    expect(m.summary).to eq "One-line summary"

    m.urls.homepage = "http://example.com"
    expect(m.urls.homepage).to eq "http://example.com"
    m.urls.api_docs = "http://example.com/api"
    expect(m.urls.api_docs).to eq "http://example.com/api"
    m.urls.download = "http://example.com/download"
    expect(m.urls.download).to eq "http://example.com/download"
    m.urls.vcs = "https://example.com/git"
    expect(m.urls.vcs).to eq "https://example.com/git"
    m.urls.tutorial = "http://tutorial.example.com"
    expect(m.urls.tutorial).to eq "http://tutorial.example.com"
    m.urls.description_source = "http://wikipedia.de/juhu"
    expect(m.urls.description_source).to eq "http://wikipedia.de/juhu"
    m.urls.announcement = "http://cnn.com/headline"
    expect(m.urls.announcement).to eq "http://cnn.com/headline"
    m.urls.mailing_list = "mailto:list@example.com"
    expect(m.urls.mailing_list).to eq "mailto:list@example.com"
    m.urls.contact = "contact@example.com"
    expect(m.urls.contact).to eq "contact@example.com"

    m.urls.custom = { "special" => "pointer" }
    expect(m.urls.custom["special"]).to eq "pointer"

    m.licenses = ["GPLv2", "LGPLv2"]
    expect(m.licenses).to eq ["GPLv2", "LGPLv2"]

    m.description = "Multi-line description\nwith info."
    expect(m.description).to eq "Multi-line description\nwith info."

    m.authors = ["Clark Kent <ck@example.com>"]
    expect(m.authors).to be_a Array
    expect(m.authors).to eq ["Clark Kent <ck@example.com>"]

    m.maturity = "stable"
    expect(m.maturity).to eq "stable"

    m.platforms = ["Linux", "Windows"]
    expect(m.platforms).to eq ["Linux", "Windows"]

    m.packages.source = "http://download.example.com/file"
    expect(m.packages.source).to eq "http://download.example.com/file"

    m.packages.openSUSE = { "something" => "here" }
    expect(m.packages.openSUSE).to eq( { "something" => "here" } )

    m.group = "kde-frameworks"
    expect(m.group).to eq "kde-frameworks"
  end

  it "constructs object from schema id" do
    m = Manifest.new(ManifestRelease.schema_id)
    expect(m.schema_version).to eq 1
  end

  it "returns descendants" do
    expect(Manifest.descendants).to be_a(Array)
    expect(Manifest.descendants.count).to be >= 3
    expect(Manifest.descendants).to include ManifestGeneric
    expect(Manifest.descendants).to include ManifestRelease
  end

  it "contructs generic manifest from schema id" do
    expect(Manifest.for_schema_id(ManifestGeneric.schema_id)).to(
      be_a ManifestGeneric)
  end

  it "contructs release manifest from schema id" do
    expect(Manifest.for_schema_id(ManifestRelease.schema_id)).to(
      be_a ManifestRelease)
  end

  it "contructs proprietary release manifest from schema id" do
    expect(Manifest.for_schema_id(ManifestProprietaryRelease.schema_id)).to(
      be_a ManifestProprietaryRelease)
  end

  describe ".is_released?" do
    it "returns release state for generic manifest without commercial license" do
      expect(ManifestGeneric.new.is_released?).to be false
    end

    it "returns release state for generic manifest with only commercial license" do
      manifest = ManifestGeneric.new
      manifest.licenses << "Commercial"
      expect(manifest.is_released?).to be true
    end

    it "returns release state for generic manifest with additional commercial license" do
      manifest = ManifestGeneric.new
      manifest.licenses << "Commercial" << "GPLv2"
      expect(manifest.is_released?).to be false
    end

    it "returns release state for release manifest" do
      expect(ManifestRelease.new.is_released?).to be true
    end

    it "returns release state for proprietary release manifest" do
      expect(ManifestProprietaryRelease.new.is_released?).to be true
    end
  end

  describe ".path" do
    it "returns generic manifest path" do
      manifest = create_generic_manifest( "mylib" )
      expect( manifest.path ).to eq( "mylib/mylib.manifest" )
    end

    it "returns release manifest path" do
      manifest = create_manifest( "mylib", "2014-02-01", "1.0" )
      expect( manifest.path ).to eq( "mylib/mylib.2014-02-01.manifest" )
    end
  end

  describe ".expected_filename" do
    it "returns expected filename for generic manifest" do
      m = ManifestGeneric.new
      m.name = "xyz"

      expect(m.expected_filename).to eq "xyz.manifest"
    end

    it "returns expected filename for release manifest" do
      m = ManifestRelease.new
      m.name = "xyz"
      m.release_date = "2014-08-14"

      expect(m.expected_filename).to eq "xyz.2014-08-14.manifest"
    end

    it "returns expected filename for proprietary release manifest" do
      m = ManifestProprietaryRelease.new
      m.name = "xyz"
      m.release_date = "2014-08-14"

      expect(m.expected_filename).to eq "xyz.2014-08-14.manifest"
    end
  end

  describe ".schema_name" do
    it "returns expected schema name for generic manifest" do
      m = ManifestGeneric.new
      expect(m.schema_name).to eq "generic-manifest-v1"
    end

    it "returns expected schema name for release manifest" do
      m = ManifestRelease.new
      expect(m.schema_name).to eq "release-manifest-v1"
    end

    it "returns expected schema name for proprietary release manifest" do
      m = ManifestProprietaryRelease.new
      expect(m.schema_name).to eq "proprietary-release-manifest-v1"
    end
  end

  describe ".has_version?" do
    it "returns if generic manifest has version" do
      expect(ManifestGeneric.new.has_version?).to be false
    end

    it "returns if release manifest has version" do
      expect(ManifestGeneric.new.has_version?).to be false
    end

    it "returns if proprietary release manifest has version" do
      expect(ManifestGeneric.new.has_version?).to be false
    end
  end
end
