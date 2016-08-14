require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem

  describe "view" do
    before(:each) do
      @output_dir = given_directory
      run_command(args: ["view", "--output-dir=#{@output_dir}"])
    end

    it "generates inqlude-all.json from online data" do
      data = File.read(File.join(@output_dir, 'inqlude-all.json'))
      parsed_data = JSON.parse(data);

      settings = Settings.new
      handler = ManifestHandler.new settings
      handler.read_remote

      expect(handler.libraries.length).to eq parsed_data.length

      for element in parsed_data do
        if element["name"] == "baloo"
        library = element
        break
        end
      end

      manifest = handler.library("baloo").latest_manifest

      expect(manifest.display_name).to eq library["display_name"]
      expect(manifest.release_date).to eq library["release_date"]
      expect(manifest.version).to eq library["version"]
      expect(manifest.summary).to eq library["summary"]
      expect(manifest.topics).to eq library["topics"]

      expect(manifest.urls.homepage).to eq library["urls"]["homepage"]
      expect(manifest.urls.api_docs).to eq library["urls"]["api_docs"]
      expect(manifest.urls.download).to eq library["urls"]["download"]
      expect(manifest.urls.tutorial).to eq library["urls"]["tutorial"]
      expect(manifest.urls.vcs).to eq library["urls"]["vcs"]
      expect(manifest.urls.description_source).to eq library["urls"]["description_source"]
      expect(manifest.urls.announcement).to eq library["urls"]["announcement"]
      expect(manifest.urls.mailing_list).to eq library["urls"]["mailing_list"]
      expect(manifest.urls.contact).to eq library["urls"]["contact"]
      expect(manifest.urls.custom).to eq library["urls"]["custom"]

      expect(manifest.licenses).to eq library["licenses"]
      expect(manifest.description).to eq library["description"]
      expect(manifest.authors).to eq library["authors"]
      expect(manifest.maturity).to eq library["maturity"]

      expect(manifest.packages.source).to eq library["packages"]["source"]
      expect(manifest.packages.openSUSE).to eq library["packages"]["openSUSE"]
      expect(manifest.packages.windows).to eq library["packages"]["windows"]
      expect(manifest.packages.ubuntu).to eq library["packages"]["ubuntu"]
      expect(manifest.packages.osx).to eq library["packages"]["osx"]
    end
  end
end
