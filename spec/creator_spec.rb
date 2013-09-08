require File.expand_path('../spec_helper', __FILE__)

describe Creator do

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end

  let(:filename) do
    File.expand_path('../data/awesomelib/awesomelib.2013-10-01.manifest', __FILE__)
  end
  
  it "checks directory" do
    c = Creator.new settings, "xxx"
    expect{ c.validate_directory }.to raise_error(StandardError)

    c = Creator.new settings, "awesomelib"
    c.validate_directory
  end

  it "create updated manifest" do
    c = Creator.new settings, "awesomelib"

    File.exists?(filename).should be_false

    c.create "1.0", "2013-10-01"

    File.exists?(filename).should be_true

    mh = ManifestHandler.new settings
    mh.read_remote

    mh.libraries.count.should == 1
    m = mh.manifest "awesomelib"
    m["name"].should == "awesomelib"
    m["version"].should == "1.0"
    m["release_date"].should == "2013-10-01"
    m["summary"].should == "Awesome library"

    mh.manifests.count.should == 2
    mh.manifests.each do |manifest|
      manifest.keys.count.should == 14
    end

    m = JSON File.read(filename)
    m.keys.count.should == 13
  end

  after(:each) do
    File.delete filename if File.exists? filename
  end
  
end
