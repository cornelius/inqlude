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
        @output_dir = given_directory
        run_command(args: ["view", "--output-dir=#{@output_dir}"])
      end

      it "generates view" do
        expect(File.exist?(File.join(@output_dir, "inqlude-all.json"))).to be(true)
      end

      it "checks format" do
        data = File.read(File.join(@output_dir, 'inqlude-all.json'))

        expect {JSON.parse(data)}.to_not raise_error
      end

      it "checks number of manifests" do
        data = File.read(File.join(@output_dir, 'inqlude-all.json'))
        parsed_data = JSON.parse(data);

        settings = Settings.new
        handler = ManifestHandler.new settings
        handler.read_remote

        expect(handler.libraries.length).to eq parsed_data.length
      end

      it "checks data" do
        data = File.read(File.join(@output_dir, 'inqlude-all.json'))
        parsed_data = JSON.parse(data);
        for element in parsed_data do
          if element["name"] == "baloo"
            library = element
            break
          end
        end

        settings = Settings.new
        handler = ManifestHandler.new settings
        handler.read_remote
        manifest = handler.library("baloo").latest_manifest

        (expect manifest.display_name).to eq library["display_name"]
        (expect manifest.release_date).to eq library["release_date"]
        (expect manifest.version).to eq library["version"]
        (expect manifest.summary).to eq library["summary"]
        (expect manifest.topics).to eq library["topics"]

        (expect manifest.urls.homepage).to eq library["urls"]["homepage"]
        (expect manifest.urls.api_docs).to eq library["urls"]["api_docs"]
        (expect manifest.urls.download).to eq library["urls"]["download"]
        (expect manifest.urls.tutorial).to eq library["urls"]["tutorial"]
        (expect manifest.urls.vcs).to eq library["urls"]["vcs"]
        (expect manifest.urls.description_source).to eq library["urls"]["description_source"]
        (expect manifest.urls.announcement).to eq library["urls"]["announcement"]
        (expect manifest.urls.mailing_list).to eq library["urls"]["mailing_list"]
        (expect manifest.urls.contact).to eq library["urls"]["contact"]
        (expect manifest.urls.custom).to eq library["urls"]["custom"]

        (expect manifest.licenses).to eq library["licenses"]
        (expect manifest.description).to eq library["description"]
        (expect manifest.authors).to eq library["authors"]
        (expect manifest.maturity).to eq library["maturity"]

        (expect manifest.packages.source).to eq library["packages"]["source"]
        (expect manifest.packages.openSUSE).to eq library["packages"]["openSUSE"]
        (expect manifest.packages.windows).to eq library["packages"]["windows"]
        (expect manifest.packages.ubuntu).to eq library["packages"]["ubuntu"]
        (expect manifest.packages.osx).to eq library["packages"]["osx"]
      end
    end
  end
end
