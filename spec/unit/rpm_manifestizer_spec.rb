require File.expand_path('../spec_helper', __FILE__)

describe RpmManifestizer do

  it "detects libraries" do
    m = RpmManifestizer.new Settings.new
    expect(m.is_library?( "libjson" )).to be true
    expect(m.is_library?( "kontact" )).to be false
  end

end
