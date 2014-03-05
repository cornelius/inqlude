require File.expand_path('../spec_helper', __FILE__)

describe Library do

  it "lists versions" do
    versions = [ "1.0", "2.0" ]

    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    versions.each do |version|
      manifests.push create_manifest "mylib", "2014-02-03", version
    end

    library = Library.new
    library.manifests = manifests

    library.versions.should == versions
  end
  
  it "returns generic manifest" do
    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    manifests.push create_manifest "mylib", "2014-02-03", "1.0"
    
    library = Library.new
    library.manifests = manifests
    
    expect( library.generic_manifest["name"] ).to eq "mylib"
    expect( library.generic_manifest["schema_type"] ).to eq "generic"
  end
  
  it "returns relase manifests" do
    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    manifests.push create_manifest "mylib", "2014-02-03", "1.0"
    manifests.push create_manifest "mylib", "2014-03-03", "1.1"
    
    library = Library.new
    library.manifests = manifests
    
    expect( library.release_manifests.count ).to eq 2
    library.release_manifests.each do |release_manifest|
      expect( release_manifest["schema_type"] ).to eq "release"
    end
  end
  
  it "returns latest manifest from multiple releases" do
    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    manifests.push create_manifest "mylib", "2014-02-03", "1.0"
    manifests.push create_manifest "mylib", "2014-03-03", "1.1"
    
    library = Library.new
    library.manifests = manifests
    
    expect( library.latest_manifest["schema_type"] ).to eq "release"
    expect( library.latest_manifest["version"] ).to eq "1.1"
  end

  it "returns latest manifest from generic manifest" do
    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    
    library = Library.new
    library.manifests = manifests
    
    expect( library.latest_manifest["schema_type"] ).to eq "generic"
    expect( library.latest_manifest["version"] ).to be_nil
  end

end
