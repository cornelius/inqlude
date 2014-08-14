require File.expand_path('../spec_helper', __FILE__)

describe Verifier do

  include_context "manifest_files"
  
  it "defines result class" do
    r = Verifier::Result.new
    expect(r.valid?).to be true
    expect(r.errors.class).to be Array
  end
  
  it "verifies read manifests" do
    handler = ManifestHandler.new settings
    handler.read_remote

    verifier = Verifier.new settings
    expect(verifier.verify( handler.manifest("awesomelib") ).class).to be Verifier::Result
    expect(verifier.verify( handler.manifest("awesomelib") ).valid?).to be true
  end

  it "detects incomplete manifest" do
    verifier = Verifier.new settings

    manifest = ManifestRelease.new
    expect(verifier.verify( manifest ).valid?).to be false
  end
      
  it "detects invalid entries" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    expect(verifier.verify(manifest).valid?).to be true

    expect{ manifest.invalidentry }.to raise_error
    expect{ manifest["invalidentry"] }.to raise_error
  end

  it "detects name mismatch" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    expect(verifier.verify(manifest).valid?).to be true
    
    manifest.filename = "wrongname"
    expect(verifier.verify(manifest).valid?).to be false
  end

  it "verifies release manifest file" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    
    verifier = Verifier.new settings

    expect( verifier.verify_file( filename ).valid? ).to be true
  end

  it "verifies generic manifest file" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    
    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be true
  end
  
  it "verifies proprietary release manifest file" do
    filename = File.join settings.manifest_path, proprietarylib_manifest_file
    
    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be true
  end

  it "verifies invalid schema id" do
    filename = test_data_path("invalid-schema.manifest")

    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be false
  end
  
  it "verifies schema" do
    manifest = ManifestRelease.new
    manifest.name = "mylib"
    manifest.release_date = "2013-02-28"
    manifest.filename = "mylib.2013-02-28.manifest"
    manifest.libraryname = "mylib"
    
    verifier = Verifier.new settings
    
    errors = verifier.verify(manifest).errors

    expect( errors.class ).to be Array
    expect(errors[0]).to match /^Schema validation error/
    expect(errors.count).to eq 8
  end
  
end
