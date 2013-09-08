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

end
