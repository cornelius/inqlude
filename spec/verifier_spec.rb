require File.expand_path('../spec_helper', __FILE__)

describe Verifier do

  include_context "manifest_files"
  
  it "defines result class" do
    r = Verifier::Result.new
    r.valid?.should be_false
    r.errors.class.should == Array
  end
  
  it "verifies read manifests" do
    handler = ManifestHandler.new settings
    handler.read_remote

    verifier = Verifier.new settings
    verifier.verify( handler.manifest("awesomelib") ).class.should == Verifier::Result
    verifier.verify( handler.manifest("awesomelib") ).valid?.should be_true
  end

  it "detects incomplete manifest" do
    verifier = Verifier.new settings

    manifest = Hash.new
    verifier.verify( manifest ).valid?.should be_false
  end
      
  it "detects invalid entries" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    verifier.verify(manifest).valid?.should be_true

    manifest["invalidentry"] = "something"
    verifier.verify(manifest).valid?.should be_false
    verifier.verify(manifest).errors.count.should == 1
  end

  it "detects name mismatch" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    verifier.verify(manifest).valid?.should be_true
    
    manifest["filename"] = "wrongname"
    verifier.verify(manifest).valid?.should be_false
  end

  it "verifies release file" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file
    
    verifier = Verifier.new settings

    expect( verifier.verify_file( filename ).valid? ).to be_true
  end

  it "verifies generic file" do
    filename = File.join settings.manifest_path, newlib_manifest_file
    
    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be_true
  end
  
  it "verifies schema" do
    manifest = Hash.new
    manifest["name"] = "mylib"
    manifest["release_date"] = "2013-02-28"
    manifest["filename"] = "mylib.2013-02-28.manifest"
    manifest["libraryname"] = "mylib"
    manifest["$schema"] = "http://inqlude.org/schema/release-manifest-v1#"
    manifest["schema_type"] = "release"
    manifest["schema_version"] = 1
    
    verifier = Verifier.new settings
    
    errors = verifier.verify(manifest).errors

    expect( errors.class ).to be_equal Array    
    errors[0].should =~ /^Schema validation error/
    errors.count.should == 8
  end
  
end
