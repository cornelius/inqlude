require File.expand_path('../spec_helper', __FILE__)

describe KdeFrameworksCreator do

  include GivenFilesystemSpecHelpers

  describe "#framework" do
    it "raises error on invalid name" do
      c = KdeFrameworksCreator.new
      expect{c.framework("invalid-name")}.to raise_error(InqludeError)
    end
  end

  describe "#fill_in_data" do
    it "fills in all data" do
      c = Creator.new Settings.new, "karchive"
      manifest = c.create_generic_manifest

      k = KdeFrameworksCreator.new
      framework = {
        "title" => "KArchive",
        "introduction" => "The intro",
        "link_git_repository" => "http://git.kde.org/karchive"
      }
      k.fill_in_data framework, manifest

      expect( manifest.display_name ).to eq "KArchive"
      expect( manifest.description ).to eq "The intro"
      expect( manifest.urls.vcs ).to eq "http://git.kde.org/karchive"
    end
  end

  context "parse git checkout" do

    use_given_filesystem

    context "multi-directory checkout" do
      before(:each) do
        @checkout_path = given_directory do
          given_directory "karchive" do
            given_directory(".git")
            given_dummy_file "README.md"
            given_dummy_file "AUTHORS"
          end
          given_directory "threadweaver" do
            given_directory(".git")
            given_dummy_file "README.md"
            given_dummy_file "AUTHORS"
          end
          given_directory "kconfig" do
            given_directory(".git")
            given_dummy_file "README.md"
            given_dummy_file "AUTHORS"
          end
        end
      end

      it "parses checkout" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        expect( c.frameworks.sort ).to eq ["karchive", "kconfig", "threadweaver"]
      end

      it "generates manifests" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        output_dir = given_directory

        c.create_manifests output_dir

        expect( File.exists? File.join(output_dir,"karchive",
          "karchive.manifest") ).to be true
        expect( File.exists? File.join(output_dir,"threadweaver",
          "threadweaver.manifest") ).to be true
        expect( File.exists? File.join(output_dir,"kconfig",
          "kconfig.manifest") ).to be true
      end
    end

    it "skips non checkout directories" do
      c = KdeFrameworksCreator.new

      checkout_path = given_directory do
        given_directory("empty")
      end

      c.parse_checkout checkout_path

      expect(c.frameworks.count).to eq 0
    end

    it "parses README" do
      c = KdeFrameworksCreator.new

      framework_path = given_directory "karchive" do
        given_directory(".git")
        given_file "README.md", :from => "karchive.readme"
      end

      c.parse_readme framework_path

      karchive = c.framework("karchive")

      expect( c.errors.count ).to eq 0

      expect(karchive["title"]).to eq "KArchive"
      expect(karchive["introduction"]).to eq "KArchive provides classes for easy reading, creation and manipulation of\n\"archive\" formats like ZIP and TAR.\n\nIf also provides transparent compression and decompression of data, like the\nGZip format, via a subclass of QIODevice."
      expect(karchive["link_mailing_list"]).to eq "https://mail.kde.org/mailman/listinfo/kde-frameworks-devel"
      expect(karchive["link_git_repository"]).to eq "https://projects.kde.org/projects/frameworks/karchive/repository"
      expect(karchive["link_home_page"]).to eq "http://api.kde.org/frameworks-api/frameworks5-apidocs/karchive/html/index.html"
      expect(karchive["summary"]).to eq "Reading, creation, and manipulation of file archives"
    end

    it "parses metainfo.yaml" do
      c = KdeFrameworksCreator.new

      framework_path = given_directory "karchive" do
        given_file "metainfo.yaml", from: "karchive.metainfo.yaml"
      end

      c.parse_metainfo framework_path

      expect(c.errors.empty?).to be(true)

      karchive = c.framework("karchive")

      expect(karchive["summary"]).to eq "File compression"
    end

    it "parses AUTHORS" do
      c = KdeFrameworksCreator.new

      framework_path = given_directory "karchive" do
        given_file "AUTHORS", :from => "karchive.authors"
      end

      c.parse_authors framework_path

      karchive = c.framework("karchive")

      expect(karchive["authors"]).to eq [ "Mario Bensi <mbensi@ipsquad.net>",
        "David Faure <faure@kde.org>" ]
    end

    it "generates warnings for missing files" do
      c = KdeFrameworksCreator.new

      checkout_path = given_directory do
        given_directory "ki18n" do
          given_directory(".git")
          given_dummy_file "metainfo.yaml"
          given_dummy_file "README.md"
        end
      end

      c.parse_checkout checkout_path

      expect( c.warnings.count ).to eq 1
      expect( c.warnings.first[:name] ).to eq "ki18n"
      expect( c.warnings.first[:issue] ).to eq "missing_file"
      expect( c.warnings.first[:details] ).to eq "AUTHORS"
    end

    it "generates errors for missing fields" do
      c = KdeFrameworksCreator.new

      checkout_path = given_directory do
        given_directory "ki18n" do
          given_directory(".git")
          given_dummy_file "README.md"
        end
      end

      c.parse_checkout checkout_path

      f = c.framework("ki18n")

      expect( c.errors.count ).to eq 3

      error_hash = {}
      c.errors.each do |error|
        error_hash[error[:issue]] = error
      end

      expect( error_hash.has_key? "missing_title" ).to be true
      expect( error_hash.has_key? "missing_introduction" ).to be true
    end

    it "generates error for missing summary" do
      c = KdeFrameworksCreator.new

      checkout_path = given_directory do
        given_directory "kservice" do
          given_directory(".git")
          given_file "README.md", :from => "kservice.readme"
        end
      end

      c.parse_checkout checkout_path

      f = c.framework("kservice")

      expect( f["title"] ).to eq "KService"
      expect( f["summary"] ).to be nil

      expect( c.errors.count ).to eq 2
    end

    it "optionally doesn't generate error for missing summary" do
      c = KdeFrameworksCreator.new

      checkout_path = given_directory do
        given_directory "kservice" do
          given_directory(".git")
          given_file "README.md", :from => "kservice.readme"
        end
      end

      c.parse_checkout checkout_path, :ignore_errors => [ "link_home_page" ]

      f = c.framework("kservice")

      expect( f["title"] ).to eq "KService"
      expect( f["summary"] ).to be nil

      expect( c.errors.count ).to eq 2
    end

    context "karchive as full example" do
      before(:each) do
        @checkout_path = given_directory do
          given_directory "karchive" do
            given_directory(".git")
            given_file "README.md", :from => "karchive.readme"
            given_file "AUTHORS", :from => "karchive.authors"
            given_file "metainfo.yaml", from: "karchive.metainfo.yaml"
          end
        end
      end

      it "parses framework from checkout" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        karchive = c.framework("karchive")
        expect(karchive["title"]).to eq "KArchive"
        expect(karchive["summary"]).to eq "File compression"
        expect(karchive["link_git_repository"]).to eq "https://projects.kde.org/projects/frameworks/karchive/repository"
        expect(karchive["authors"]).to eq [ "Mario Bensi <mbensi@ipsquad.net>",
          "David Faure <faure@kde.org>" ]
      end

      it "generates manifest" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        output_dir = given_directory

        c.create_manifests output_dir

        expect( File.exists? File.join(output_dir,"karchive",
          "karchive.manifest") ).to be true

        manifest = Manifest.parse_file File.join(output_dir,"karchive",
          "karchive.manifest")

        expect( manifest.name ).to eq "karchive"
        expect( manifest.display_name ).to eq "KArchive"
        expect( manifest.urls.vcs ).to eq "https://projects.kde.org/projects/frameworks/karchive/repository"
        expect( manifest.urls.homepage ).to eq "http://api.kde.org/frameworks-api/frameworks5-apidocs/karchive/html/index.html"
        expect( manifest.description ).to eq "KArchive provides classes for easy reading, creation and manipulation of\n\"archive\" formats like ZIP and TAR.\n\nIf also provides transparent compression and decompression of data, like the\nGZip format, via a subclass of QIODevice."
        expect( manifest.urls.mailing_list ).to eq "https://mail.kde.org/mailman/listinfo/kde-frameworks-devel"
        expect( manifest.summary ).to eq "File compression"
      end

      it "overwrites existing manifests" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        output_dir = given_directory

        c.create_manifests output_dir

        expect( File.exists? File.join(output_dir,"karchive",
          "karchive.manifest") ).to be true

        c.create_manifests output_dir

        expect( File.exists? File.join(output_dir,"karchive",
          "karchive.manifest") ).to be true
      end

      it "preserves topics from generic manifest" do
        c = KdeFrameworksCreator.new

        c.parse_checkout @checkout_path

        manifest_file = nil
        output_dir = given_directory do
          given_directory "karchive" do
            manifest_file = given_file "karchive.manifest", :from => "karchive-generic-with-topics.manifest"
          end
        end

        manifest = JSON.parse(File.read(manifest_file))
        expect(manifest.has_key?("topics")).to be(true)
        expect(manifest["topics"].first).to eq("Data")

        c.create_manifests output_dir

        manifest = JSON.parse(File.read(manifest_file))
        expect(manifest.has_key?("topics")).to be(true)
        expect(manifest["topics"].first).to eq("Data")
      end
    end
  end
end
