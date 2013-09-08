require File.expand_path('../spec_helper', __FILE__)

describe Settings do

  it "has default manifest path" do
    Settings.new.manifest_path.should == File.join( ENV["HOME"], ".inqlude/manifests" )
  end

  it "lets manifest path to be set" do
    s = Settings.new
    s.manifest_path = "abc/xyz"
    s.manifest_path.should == "abc/xyz"
  end

end
