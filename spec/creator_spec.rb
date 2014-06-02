require File.expand_path('../spec_helper', __FILE__)

describe Creator do

  include GivenFilesystemSpecHelpers
  
  use_given_filesystem

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end

  it "checks directory" do
    c = Creator.new settings, "xxx"
    expect{ c.validate_directory }.to raise_error(StandardError)

    c = Creator.new settings, "awesomelib"
    c.validate_directory
  end

  it "creates updated manifest" do
    settings.manifest_path = given_directory do
      given_directory "awesomelib" do
        manifest_filename = given_file "awesomelib.2013-09-08.manifest",
          :from => "awesomelib/awesomelib.2013-09-08.manifest"
      end
    end
    manifest_filename = File.join( settings.manifest_path, "awesomelib",
                                   "awesomelib.2013-10-01.manifest" )
    
    c = Creator.new settings, "awesomelib"

    File.exists?(manifest_filename).should be_false

    c.update "1.0", "2013-10-01"

    File.exists?(manifest_filename).should be_true

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
      if manifest["schema_type"] == "generic"
        if manifest["name"] == "commercial"
          manifest.keys.count.should == 13
        else
          manifest.keys.count.should == 12
        end
      elsif manifest["schema_type"] == "proprietary-release"
        manifest.keys.count.should == 15
      else
        manifest.keys.count.should == 17
      end
    end

    m = JSON File.read(manifest_filename)
    m.keys.count.should == 13
  end

  it "creates new manifest" do
    settings.manifest_path = given_directory do
      given_directory "newawesomelib"
    end
    manifest_filename = File.join( settings.manifest_path, "newawesomelib",
                                   "newawesomelib.2013-09-01.manifest" )

    c = Creator.new settings, "newawesomelib"
    File.exists?(manifest_filename).should be_false
    
    c.create "edge", "2013-09-01"
    
    File.exists?(manifest_filename).should be_true

    mh = ManifestHandler.new settings
    mh.read_remote

    mh.libraries.count.should == 1
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

  it "creates new generic manifest" do
    settings.manifest_path = given_directory do
      given_directory "newawesomelib"
    end
    manifest_filename = File.join( settings.manifest_path, "newawesomelib",
                                   "newawesomelib.manifest" )

    c = Creator.new settings, "newawesomelib"
    File.exists?(manifest_filename).should be_false
    
    c.create_generic
    
    File.exists?(manifest_filename).should be_true

    v = Verifier.new settings
    result = v.verify_file manifest_filename
    if !result.valid?
      result.print_result
    end
    expect(result.valid?).to be_true
  end
  
  describe "#create_dir" do

    before(:each) do
      @settings = Settings.new
      @settings.manifest_path = given_directory
    end
    
    it "creates dir" do
      c = Creator.new( @settings, "one" )
      c.create_dir()
      expect( File.exists? File.join( @settings.manifest_path, "one" ) )
        .to be_true
      expect( File.directory? File.join( @settings.manifest_path, "one" ) )
        .to be_true
    end
    
    it "uses existing dir" do
      c = Creator.new( @settings, "one" )
      c.create_dir()
      c.create_dir()
      expect( File.exists? File.join( @settings.manifest_path, "one" ) )
        .to be_true
      expect( File.directory? File.join( @settings.manifest_path, "one" ) )
        .to be_true
    end
  end
  
end
