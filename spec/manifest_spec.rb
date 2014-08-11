require File.expand_path('../spec_helper', __FILE__)

describe Manifest do

  include_context "manifest_files"
  
  it "provides schema identifier" do
    expect(Manifest.release_schema_id).to include("inqlude.org")
    expect(Manifest.release_schema_id).to include("release")

    expect(Manifest.generic_schema_id).to include("inqlude.org")
    expect(Manifest.generic_schema_id).to include("generic")

    expect(Manifest.proprietary_release_schema_id).to include("inqlude.org")
    expect(Manifest.proprietary_release_schema_id).to include("proprietary")
  end
  
  it "parses schema id" do
    expect{Manifest.parse_schema_id("xxx")}.to raise_error StandardError

    type, version = Manifest.parse_schema_id(
      "http://inqlude.org/schema/release-manifest-v1#" )
    expect(type).to eq "release"
    expect(version).to eq 1

    type, version = Manifest.parse_schema_id(
      "http://inqlude.org/schema/release-manifest-v2#" )
    expect(type).to eq "release"
    expect(version).to eq 2

    type, version = Manifest.parse_schema_id(
      "http://inqlude.org/schema/generic-manifest-v1#" )
    expect(type).to eq "generic"
    expect(version).to eq 1
  end
  
  it "parses release manifest" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    manifest = Manifest.parse_file filename
    expect(manifest).to be_a Manifest
    expect(manifest.name).to eq "awesomelib"
    expect(manifest.version).to eq "0.2.0"

    expect(manifest.filename).to eq "awesomelib.2013-09-08.manifest"
    expect(manifest.libraryname).to eq "awesomelib"

    expect(manifest.schema_type).to eq "release"
    expect(manifest.schema_version).to eq 1
  end

  it "parses generic manifest" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    manifest = Manifest.parse_file filename
    expect(manifest).to be_a Manifest
    expect(manifest.name).to eq "newlib"
    expect(manifest.version).to eq nil

    expect(manifest.filename).to eq "newlib.manifest"

    expect(manifest.schema_type).to eq "generic"
    expect(manifest.schema_version).to eq 1
  end

  it "writes JSON for release manifest" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    manifest = Manifest.parse_file filename
    expect( Manifest.to_json( manifest ) ).to eq File.read( filename )
  end

  it "writes JSON for generic manifest" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    manifest = Manifest.parse_file filename
    expect( Manifest.to_json( manifest ) ).to eq File.read( filename )
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

    m.group = "kde-frameworks"
    expect(m.group).to eq "kde-frameworks"
  end

  it "constructs object from schema id" do
    m = Manifest.new(Manifest::release_schema_id)
    expect(m.schema_type).to eq "release"
    expect(m.schema_version).to eq 1
  end

  it "constructs generic schema" do
    m = ManifestGeneric.new
    expect(m.schema_type).to eq "generic"
  end

  it "constructs proprietary schema" do
    m = ManifestProprietaryRelease.new
    expect(m.schema_type).to eq "proprietary-release"
  end

  it "constructs release schema" do
    m = ManifestRelease.new
    expect(m.schema_type).to eq "release"
  end
end
