require File.expand_path('../spec_helper', __FILE__)

describe GivenFilesystem do

  include HasGivenFilesystem

  context "not initialized" do
    describe "#given_directory" do
      it "raises error" do
        expect{ given_directory }.to raise_error /given_filesystem/
      end
    end
    
    describe "#given_file" do
      it "raises error" do
        expect{ given_directory }.to raise_error /given_filesystem/
      end
    end
  end
  
  context "using the module" do
    given_filesystem

    describe "#given_directory" do
      it "creates unnamed directory" do
        path = given_directory
        expect( File.exists? path ).to be_true
        expect( File.directory? path ).to be_true
      end
      
      it "creates directory" do
        path = given_directory "hello"
        expect( path ).to match /\/hello$/      
      end
      
      it "creates nested directory" do
        path = nil
        given_directory "hello" do
          path = given_directory "world"
        end
        expect( path ).to match /\/hello\/world$/
      end
    end

    describe "#given_file" do
      it "creates unnamed dummy file" do
        path = given_dummy_file
        expect( File.exists? path ).to be_true
        expect( File.directory? path ).to be_false
      end
      
      it "creates named dummy file" do
        path = given_dummy_file "welcome"
        expect( path ).to match /\/welcome$/
        expect( File.exists? path ).to be_true
        expect( File.directory? path ).to be_false
      end

      it "creates file with content" do
        path = given_file "testcontent"
        expect( path ).to match /\/testcontent$/
        expect( File.read( path ) ).to eq "This is my test content.\n"
      end
      
      it "creates file with content and given filename" do
        path = given_file "welcome", :from => "testcontent"
        expect( path ).to match /\/welcome$/
        expect( File.read( path ) ).to eq "This is my test content.\n"
      end
      
      it "creates file in directory" do
        path = nil
        given_directory "hello" do
          path = given_file "world", :from => "testcontent"
        end
        expect( File.exists? path ).to be_true
        expect( File.read( path ) ).to eq "This is my test content.\n"
      end
    end
  end
  
  context "creating directory tree" do
  
    before(:each) do
      @given = GivenFilesystem.new
    end
    
    after(:each) do
      @given.cleanup
    end
    
    it "creates direcory" do
      path = @given.directory
      expect( File.exists? path ).to be_true
      expect( File.directory? path ).to be_true
      expect( path ).to match /tmp/
      expect( path.split("/").length).to be > 3
    end
    
    it "creates named directory" do
      path = @given.directory "abc"
      expect( path ).to match /tmp/
      expect( path.split("/").length).to be > 4
      expect( path ).to match /abc$/    
    end
    
    it "creates file" do
      path = @given.file
      expect( path ).to match /tmp/
      expect( path.split("/").length).to be > 3
      expect( File.exists? path ).to be_true
      expect( File.directory? path ).to be_false
    end
    
    it "creates named file" do
      path = @given.file "def"
      expect( path ).to match /tmp/
      expect( path.split("/").length).to be > 4
      expect( path ).to match /def$/
    end
    
    it "throws error on invalid test data file name" do
      expect{@given.file "def", :from => "invalidname"}.to raise_error
    end
    
    it "creates file with content" do
      path = @given.file "def", :from => "testcontent"
      expect( path ).to match /tmp/
      expect( path.split("/").length).to be > 4
      expect( path ).to match /def$/
      expect( File.read(path) ).to eq "This is my test content.\n"
    end
    
    it "creates directory tree" do
      path = @given.directory do
        @given.directory "one" do
          @given.file "first"
        end
        @given.directory "two" do
          @given.file "second"
          @given.file "third"
        end
      end
      
      expect( File.exists? path).to be_true
      expect( File.directory? path).to be_true
      expect( File.exists? File.join(path,"one")).to be_true
      expect( File.exists? File.join(path,"one")).to be_true
      expect( File.directory? File.join(path,"one")).to be_true
      expect( File.directory? File.join(path,"two")).to be_true
      expect( File.exists? File.join(path,"one","first")).to be_true
      expect( File.exists? File.join(path,"two","second")).to be_true
      expect( File.exists? File.join(path,"two","third")).to be_true
    end
    
    it "returns paths" do
      path1 = @given.directory "one"
      expect( path1 ).to match /^\/tmp\/given_filesystem\/[\d-]+\/one$/

      path2 = @given.directory "two"
      expect( path2 ).to match /^\/tmp\/given_filesystem\/[\d-]+\/two$/
      
      path3 = @given.directory "three" do
        @given.file "first"
      end
      expect( path3 ).to match /^\/tmp\/given_filesystem\/[\d-]+\/three$/
    end
  end

  context "cleaning up" do
    it "cleans up directory tree" do
      given = GivenFilesystem.new
      path1 = given.directory
      path2 = given.directory
      
      expect( File.exists? path1).to be_true
      expect( File.exists? path2).to be_true
      
      given.cleanup
      
      expect( File.exists? path1).to be_false
      expect( File.exists? path2).to be_false
    end
  end
end
