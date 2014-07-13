require File.expand_path('../spec_helper', __FILE__)

describe Settings do

  it "has default manifest path" do
    expect(Settings.new.manifest_path). to eq File.join( ENV["HOME"], ".inqlude/manifests" )
  end

  it "lets manifest path to be set" do
    s = Settings.new
    s.manifest_path = "abc/xyz"
    expect(s.manifest_path).to eq "abc/xyz"
  end

end
