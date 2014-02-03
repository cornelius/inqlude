require File.expand_path('../spec_helper', __FILE__)

describe Library do

  it "lists versions" do
    versions = [ "1.0", "2.0" ]

    manifests = Array.new
    versions.each do |version|
      manifests.push create_manifest "mylib", version
    end

    library = Library.new
    library.manifests = manifests

    library.versions.should == versions
  end
  
  it "returns generic manifest" do
    manifests = Array.new
    manifests.push create_generic_manifest "mylib"
    manifests.push create_manifest "mylib", "1.0"
    
    library = Library.new
    library.manifests = manifests
    
    expect( library.generic_manifest["name"] ).to eq "mylib"
    expect( library.generic_manifest["schema_type"] ).to eq "generic"
  end

end
