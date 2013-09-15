require File.expand_path('../spec_helper', __FILE__)

describe Verifier do

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end

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

end
