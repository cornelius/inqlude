require File.expand_path('../spec_helper', __FILE__)

describe View do

  include_context "manifest_files"
  
  it "shows version content" do
    mh = ManifestHandler.new settings
    mh.read_remote
    v = View.new mh

    v.library = mh.library "awesomelib"
    v.manifest = v.library.manifests.last
    
    expect(v.version_content).to include "0.2.0"
  end
  
  it "throws error on showing version content of generic manifest" do
    mh = ManifestHandler.new settings
    mh.read_remote
    v = View.new mh

    v.library = mh.library "newlib"
    v.manifest = v.library.manifests.last
    
    expect{v.version_content}.to raise_error RuntimeError
  end

  it "returns list of unreleased libraries" do
    mh = ManifestHandler.new settings
    mh.read_remote
    v = View.new mh
    
    expect(v.unreleased_libraries.count).to eq 1
    expect(v.unreleased_libraries.first.name).to eq "newlib"
  end
  
end
