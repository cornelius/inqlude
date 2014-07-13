require File.expand_path('../spec_helper', __FILE__)

describe View do

  context "general libraries" do
    include_context "manifest_files"
    
    it "shows version content" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh

      v.library = mh.library "awesomelib"
      v.manifest = v.library.latest_manifest
      
      expect(v.version_content).to include "0.2.0"
    end
    
    it "throws error on showing version content of generic manifest" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh

      v.library = mh.library "newlib"
      v.manifest = v.library.latest_manifest
      
      expect{v.version_content}.to raise_error RuntimeError
    end

    it "returns list of unreleased libraries" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh
      
      expect(v.unreleased_libraries.count).to eq mh.unreleased_libraries.count
      expect(v.unreleased_libraries.first.name).to eq mh.unreleased_libraries.first.name
    end
    
    it "returns list of commercial libraries" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh
      
      expect(v.commercial_libraries.count).to eq mh.commercial_libraries.count
      expect(v.commercial_libraries.first.name).to eq mh.commercial_libraries.first.name
    end
    
    it "returns group" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh
      v.group_name = "kde-frameworks"
      
      expect(v.group.count).to eq mh.group("kde-frameworks").count
      expect(v.group.first.name).to eq mh.group("kde-frameworks").first.name
    end
  end
  
  context "generic manifest and one release" do
    
    include GivenFilesystemSpecHelpers
    
    use_given_filesystem

    before(:each) do
      @manifest_dir = given_directory do
        given_directory("karchive") do
          given_file("karchive.manifest", :from => "karchive-generic.manifest")
          given_file("karchive.2014-02-01.manifest", :from => "karchive-release-beta.manifest")
        end
      end
      
      s = Settings.new
      s.manifest_path = @manifest_dir
      s.offline = true
      @manifest_handler = ManifestHandler.new s
      @manifest_handler.read_remote
    end
    
    it "shows version content" do
      v = View.new @manifest_handler

      v.library = @manifest_handler.library "karchive"
      v.manifest = v.library.latest_manifest
      
      expect(v.version_content).to include "4.9.90"
      expect(v.version_content).not_to include( "older versions" )
    end
    
  end

  context "generic manifest and two releases" do
    
    include GivenFilesystemSpecHelpers
    
    use_given_filesystem

    before(:each) do
      @manifest_dir = given_directory do
        given_directory("karchive") do
          given_file("karchive.manifest", :from => "karchive-generic.manifest")
          given_file("karchive.2014-02-01.manifest", :from => "karchive-release-beta.manifest")
          given_file("karchive.2014-03-04.manifest", :from => "karchive-release2.manifest")
        end
      end
      
      s = Settings.new
      s.manifest_path = @manifest_dir
      s.offline = true
      @manifest_handler = ManifestHandler.new s
      @manifest_handler.read_remote
    end
    
    it "shows version content" do
      v = View.new @manifest_handler

      v.library = @manifest_handler.library "karchive"
      v.manifest = v.library.latest_manifest
      expect(v.version_content).to include "4.9.90"
      expect(v.version_content).to include "4.97.0"
      expect(v.version_content).to include( "older versions" )
    end
    
  end

end
