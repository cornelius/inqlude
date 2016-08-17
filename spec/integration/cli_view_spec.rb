require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem

  describe "view" do
    it "generates view" do
      dir = given_directory do
        given_directory_from_data("awesomelib", from: "manifests/awesomelib")
        given_directory_from_data("newlib", from: "manifests/newlib")
      end

      output_dir = given_directory

      result = run_command(args: ["view", "--offline",
        "--manifest_dir=#{dir}", "--output-dir=#{output_dir}"])
      expect(result).to exit_with_success(/Creating web site/)

      expect(File.exist?(File.join(output_dir, "index.html"))).to be(true)
      expect(File.exist?(File.join(output_dir, "libraries", "awesomelib.html"))).to be(true)
      expect(File.exist?(File.join(output_dir, "libraries", "newlib.html"))).to be(true)
    end

    it "checks templates direstory" do
      dir = given_directory do
        given_directory_from_data("awesomelib", from: "manifests/awesomelib")
        given_directory_from_data("newlib", from: "manifests/newlib")
      end

      output_dir = given_directory

      result = run_command(args: ["view", "--offline", "--manifest_dir=#{dir}",
        "--output-dir=#{output_dir}", "--templates=one-column"])
      expect(result).to exit_with_success(/Creating web site/)

      result = run_command(args: ["view", "--offline", "--manifest_dir=#{dir}",
        "--output-dir=#{output_dir}", "--templates=unreal-template"])
      expected_output = <<EOT
Error: Templates directory doesn't exist
EOT
      expect(result).to exit_with_error(1, expected_output)
    end

    it "generates templates" do
      dir = given_directory do
        given_directory_from_data("awesomelib", from: "manifests/awesomelib")
        given_directory_from_data("newlib", from: "manifests/newlib")
      end

      output_dir = given_directory

      result = run_command(args: ["view", "--offline", "--manifest_dir=#{dir}",
        "--output-dir=#{output_dir}", "--templates=one-column"])
      expect(result).to exit_with_success(/Creating web site/)

      expect(File.exist?(File.join(output_dir, "index.html"))).to be(true)
      expect(File.exist?(File.join(output_dir, "libraries", "awesomelib.html"))).to be(true)
      expect(File.exist?(File.join(output_dir, "libraries", "newlib.html"))).to be(true)
    end
    
    context "inqlude-all.json" do
      before(:each) do
        @manifest_dir = given_directory do
          given_directory_from_data("awesomelib", from: "manifests/awesomelib")
          given_directory_from_data("newlib", from: "manifests/newlib")
        end

        @output_dir = given_directory

        run_command(args: ["view",  "--offline", "--manifest_dir=#{@manifest_dir}",
          "--output-dir=#{@output_dir}"])
      end

      it "checks number of manifests" do
        data = File.read(File.join(@output_dir, 'inqlude-all.json'))
        parsed_data = JSON.parse(data);

        settings = Settings.new
        settings.manifest_path = @manifest_dir
        settings.offline = true
        handler = ManifestHandler.new settings
        handler.read_remote

        expect(handler.libraries.length).to eq parsed_data.length
      end

      it "checks content" do
        data = File.read(File.join(@output_dir, 'inqlude-all.json'))
        parsed_data = JSON.parse(data);
        for element in parsed_data do
          if element["name"] == "awesomelib"
            library = element
            break
          end
        end
        
        expect(library).to be

        settings = Settings.new
        handler = ManifestHandler.new settings
        settings.manifest_path = @manifest_dir
        settings.offline = true
        handler.read_remote

        manifest = handler.library("awesomelib").latest_manifest

        expect(manifest.display_name).to eq "Awesomelib"
        expect(manifest.release_date).to eq "2013-09-08"
        expect(manifest.version).to eq "0.2.0"
        expect(manifest.summary).to eq "Awesome library"
        expect(manifest.topics).to eq ["API"]

        expect(manifest.urls.homepage).to eq "http://example.com"
        expect(manifest.urls.download).to eq "http://example.com/download"
        expect(manifest.urls.vcs).to eq "http://example.com/git"

        expect(manifest.licenses).to eq ["LGPLv2.1+", "Commercial"]
        expect(manifest.description).to eq "This is an awesome library."
        expect(manifest.authors).to eq ["Cornelius Schumacher <schumacher@kde.org>"]
        expect(manifest.maturity).to eq "stable"

        expect(manifest.packages.source).to eq "ftp://example.com/download/awesomelib-0.2.0.tar.gz"
      end
    end
  end
end
