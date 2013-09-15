require File.expand_path('../spec_helper', __FILE__)

describe ManifestHandler do

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end
  
  it "reads manifests" do
    mh = ManifestHandler.new settings
    mh.read_remote
    mh.manifests.count.should == 1
    mh.libraries.count.should == 1
    mh.read_remote
    mh.manifests.count.should == 1
    mh.libraries.count.should == 1
  end

  it "provides access to manifests" do
    mh = ManifestHandler.new settings
    mh.read_remote

    mh.manifest("awesomelib").class.should == Hash
    expect { mh.manifest("nonexisting") }.to raise_error
  end
  
end
