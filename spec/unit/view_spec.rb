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
      
      expect{v.version_content}.to raise_error(InqludeError)
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

    it "returns topic" do
      mh = ManifestHandler.new settings
      mh.read_remote
      v = View.new mh

      expect(v.topic("API").count).to eq (mh.topic("API").count)
      expect(v.topic("API").first.name).to eq (mh.topic("API").first.name)
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

    it "creates inqlude-all.json" do
      v = View.new @manifest_handler
      dir = given_directory

      v.create_inqlude_all(dir)

      all_path = File.join(dir, "inqlude-all.json")
      expect(File.exists?(all_path)).to be true
      expected_all_content = File.read(test_data_path("inqlude-all-karchive.json"))
      expect(File.read(all_path)).to eq expected_all_content
    end
    
  end

  context "rendertest" do
    before(:each) do
      @view = View.new double
      @view.manifest = Manifest.parse_file(test_data_path("rendertest-generic.manifest"))
    end

    it "renders description as markdown" do
      rendered = @view.render_description

      expected = <<EOT
<p>This description tests rendering. It tests rendering markdown to HTML.</p>

<p>This includes:</p>

<ul>
  <li>Paragraphs</li>
  <li>Lists</li>
</ul>
EOT

      expect(rendered).to eq expected
    end

    it "generates link items" do
      expected_html = "<li><a href=\"https://example.org/git\">Code</a></li>"
      expect(@view.link_item("vcs", "Code")).to eq expected_html
    end

    it "generates custom URLs" do
      expected_html = "<li><a href=\"http://special.example.org\">Special</a></li>"
      expect(@view.custom_urls).to eq expected_html
    end

    it "returns if there are more URLs" do
      expect(@view.more_urls?).to be true
    end
  end

  context "templates" do

    include GivenFilesystemSpecHelpers

    use_given_filesystem

    before(:each) do
      s = Settings.new
      mh = ManifestHandler.new s
      mh.read_remote

      v = View.new mh
      v.templates = "one-column"

      dir = given_directory

      v.create(dir)
      @path = File.join(dir, "index.html")
    end

    it "generates templates" do
      expect(File.exists?(@path)).to be true
    end

    it "checks content" do
      html_data = File.read(@path)

      nokogiri_object = Nokogiri::HTML(html_data)
      paragraphs_content = nokogiri_object.xpath("//p").to_s

      expected_content =
      '<p>
        The goal of Inqlude is to provide a comprehensive listing of all
        existing libraries for developers of Qt applications. If you are creating
        applications using the <a href="http://qt-project.org">Qt toolkit</a>, and
        are looking for libraries, components
        or modules to use, Inqlude is the place where you find all information and
        pointers to get started.
      </p><p>
        This is a young project, we are still collecting information, and are
        building up the web site and the tools around it. If you would like to get
        involved, read more about <a href="contribute.html">how to contribute</a>, or go
        to the mailing list
        <a href="https://mail.kde.org/mailman/listinfo/inqlude">inqlude.kde.org</a>
        to directly talk to us. See you there.
      </p>'

      expect(paragraphs_content).to eq(expected_content)
    end
  end
end
