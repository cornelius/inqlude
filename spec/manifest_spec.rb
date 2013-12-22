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
    expect(manifest["name"]).to eq "awesomelib"
    expect(manifest["version"]).to eq "0.2.0"
    expect(manifest["filename"]).to eq "awesomelib.2013-09-08.manifest"
    expect(manifest["libraryname"]).to eq "awesomelib"
    expect(manifest["schema_type"]).to eq "release"
    expect(manifest["schema_version"]).to eq 1
  end

  it "parses generic manifest" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    manifest = Manifest.parse_file filename
    expect(manifest["name"]).to eq "newlib"
    expect(manifest.has_key? "version").to eq false
    expect(manifest["filename"]).to eq "newlib.manifest"
    expect(manifest["schema_type"]).to eq "generic"
    expect(manifest["schema_version"]).to eq 1
  end

end
