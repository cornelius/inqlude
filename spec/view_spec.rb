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
    
    expect(v.unreleased_libraries.count).to eq mh.unreleased_libraries.count
    expect(v.unreleased_libraries.first.name).to eq mh.unreleased_libraries.first.name
  end
  
  it "returns list of commercial libraries" do
    mh = ManifestHandler.new settings
    mh.read_remote
    v = View.new mh
    
    expect(v.commercial_libraries.count).to eq mh.commercial_libraries.count
    expect(v.commercial_libraries.first.name).to eq mh.commercial_libraries.first.name
  end
  
  it "returns group" do
    mh = ManifestHandler.new settings
    mh.read_remote
    v = View.new mh
    v.group_name = "kde-frameworks"
    
    expect(v.group.count).to eq mh.group("kde-frameworks").count
    expect(v.group.first.name).to eq mh.group("kde-frameworks").first.name
  end
end
