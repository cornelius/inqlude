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

  let(:new_filename) do
    File.expand_path('../data/newawesomelib/newawesomelib.2013-09-01.manifest', __FILE__)
  end

  let(:new_dirname) do
    File.expand_path('../data/newawesomelib', __FILE__)
  end
  
  it "checks directory" do
    c = Creator.new settings, "xxx"
    expect{ c.validate_directory }.to raise_error(StandardError)

    c = Creator.new settings, "awesomelib"
    c.validate_directory
  end

  it "creates updated manifest" do
    c = Creator.new settings, "awesomelib"

    File.exists?(filename).should be_false

    c.update "1.0", "2013-10-01"

    File.exists?(filename).should be_true

    mh = ManifestHandler.new settings
    mh.read_remote

    mh.libraries.count.should == 3
    m = mh.manifest "awesomelib"
    m["name"].should == "awesomelib"
    m["version"].should == "1.0"
    m["release_date"].should == "2013-10-01"
    m["summary"].should == "Awesome library"

    mh.manifests.count.should == 4
    mh.manifests.each do |manifest|
      if manifest["schema_type"] == "generic"
        manifest.keys.count.should == 14
      else
        manifest.keys.count.should == 16
      end
    end

    m = JSON File.read(filename)
    m.keys.count.should == 14
  end

  it "creates new manifest" do
    c = Creator.new settings, "newawesomelib"
    File.exists?(new_filename).should be_false
    
    c.create "edge", "2013-09-01"
    
    File.exists?(new_filename).should be_true

    mh = ManifestHandler.new settings
    mh.read_remote

    mh.libraries.count.should == 4
    m = mh.manifest "newawesomelib"
    m["name"].should == "newawesomelib"
    m["version"].should == "edge"
    m["release_date"].should == "2013-09-01"
    
    v = Verifier.new settings
    result = v.verify m
    if !result.valid?
      result.print_result
    end
    expect(result.valid?).to be_true
  end
  
  after(:each) do
    File.delete filename if File.exists? filename
    File.delete new_filename if File.exists? new_filename
    Dir.delete new_dirname if File.exists? new_dirname
  end
  
end
