require File.expand_path('../spec_helper', __FILE__)

describe RpmManifestizer do

  it "detects libraries" do
    m = RpmManifestizer.new Settings.new
    m.is_library?( "libjson" ).should be_true
    m.is_library?( "kontact" ).should be_false
  end

end
