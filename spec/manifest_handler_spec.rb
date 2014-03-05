require File.expand_path('../spec_helper', __FILE__)

include HasGivenFilesystem

describe ManifestHandler do

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end
  
  let(:mh) do
    mh = ManifestHandler.new settings
    mh.read_remote
    mh
  end
  
  it "reads manifests" do
    mh.manifests.count.should == 5
    mh.libraries.count.should == 5
    mh.read_remote
    mh.manifests.count.should == 5
    mh.libraries.count.should == 5
  end

  it "provides access to manifests" do
    mh.manifest("awesomelib").class.should == Hash
    expect { mh.manifest("nonexisting") }.to raise_error
  end

  it "reads schema type" do
    mh.manifest("awesomelib")["schema_type"].should == "release"
    mh.manifest("newlib")["schema_type"].should == "generic"
    mh.manifest("proprietarylib")["schema_type"].should == "proprietary-release"
  end

  context "default manifest path" do
    before(:each) do
      @handler = ManifestHandler.new Settings.new
    end

    it "returns generic manifest path" do
      manifest = create_generic_manifest( "mylib" )
      expect( @handler.manifest_path( manifest ) ).to eq(
        File.expand_path( "~/.inqlude/manifests/mylib/mylib.manifest" ) )
    end

    it "returns release manifest path" do
      manifest = create_manifest( "mylib", "2014-02-01", "1.0" )
      expect( @handler.manifest_path( manifest ) ).to eq(
        File.expand_path( "~/.inqlude/manifests/mylib/mylib.2014-02-01.manifest" ) )
    end
  end
  
  describe "#libraries" do

    it "returns all libraries" do
      expect( mh.libraries.count ).to eq 5
    end
    
    it "returns stable libraries" do
      libraries = mh.libraries :stable
      expect( libraries.count ).to eq 2
      expect( libraries.first.manifests.last["name"] ).to eq "awesomelib"
      expect( libraries.first.manifests.last["version"] ).to eq "0.2.0"
    end
    
    it "returns development versions" do
      libraries = mh.libraries :edge
      expect( libraries.count ).to eq 1
      expect( libraries.first.manifests.last["name"] ).to eq "bleedingedge"
      expect( libraries.first.manifests.last["version"] ).to eq "edge"
    end
    
    it "returns unreleased libraries" do
      libraries = mh.unreleased_libraries
      expect( libraries.count ).to eq 1
      expect( libraries.first.manifests.last["name"] ).to eq "newlib"
    end
    
    it "returns commercial libraries" do
      libraries = mh.commercial_libraries
      expect( libraries.count ).to eq 3
      expect( libraries.first.manifests.last["name"] ).to eq "awesomelib"
      expect( libraries[1].manifests.last["name"] ).to eq "commercial"
    end

  end
  
  describe "#group" do
    it "returns all libraries of a group" do
      libraries = mh.group("kde-frameworks")
      expect( libraries.count ).to eq 2
      expect( libraries.first.manifests.last["name"] ).to eq "awesomelib"
    end
  end
  
  describe "#library" do
    
    it "returns one library" do
      library = mh.library "awesomelib"
      expect( library.name ).to eq "awesomelib"
    end
    
  end
  
  context "library with generic and release manifest" do
    given_filesystem

    before(:each) do
      @manifest_path = given_directory do
        given_directory "karchive" do
          given_file "karchive.manifest", :from => "karchive-generic.manifest"
          given_file "karchive.2014-02-01.manifest", :from => "karchive-release.manifest"
        end
      end
      
      s = Settings.new
      s.manifest_path = @manifest_path
      s.offline = true
      @manifest_handler = ManifestHandler.new s
      @manifest_handler.read_remote
    end
    
    it "reads generic manifest" do
      expect( @manifest_handler.library("karchive").manifests.count ).to eq 2
      generic_manifest = @manifest_handler.library("karchive").generic_manifest
      expect( generic_manifest["name"] ).to eq "karchive"
      expect( generic_manifest["schema_type"] ).to eq "generic"
    end
    
    it "lists development versions" do
      libraries = @manifest_handler.libraries :alpha
      expect( libraries.count ).to eq 1
      expect( libraries.first.latest_manifest["name"] ).to eq "karchive"
      expect( libraries.first.latest_manifest["version"] ).to eq "4.9.90"
    end
    
    it "lists unreleased libraries" do
      libraries = @manifest_handler.unreleased_libraries
      expect( libraries.count ).to eq 0
    end
  end
  
end
