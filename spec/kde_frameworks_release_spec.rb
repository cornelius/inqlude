require File.expand_path('../spec_helper', __FILE__)

describe KdeFrameworksRelease do
  
  include HasGivenFilesystem

  given_filesystem
  
  it "reads generic manifests" do
    pending
  end
  
  it "writes release manifests" do
    pending
  end

  it "creates release manifest from generic manifest" do
    k = KdeFrameworksRelease.new
    generic_manifest = Manifest.parse_file(
      given_file("karchive-generic.manifest") )
    date = "2014-02-01"
    version = "4.9.90"
    release_manifest = k.create_release_manifest( generic_manifest, date,
                                                  version )
    expected_json = File.read( given_file("karchive-release.manifest") )
    expected_json.chomp! # Remove newline added by File.read
    expect( Manifest.to_json(release_manifest) ).to eq expected_json
  end
  
end
