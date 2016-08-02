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

    context "inqlude-all.json" do
      it "generates view" do
        output_dir = given_directory
        result = run_command(args: ["view", "--output-dir=#{output_dir}"])

        expect(File.exist?(File.join(output_dir, "inqlude-all.json"))).to be(true)
      end

      it "checks format" do
        output_dir = given_directory
        result = run_command(args: ["view", "--output-dir=#{output_dir}"])
        data = File.read(File.join(output_dir, 'inqlude-all.json'))

        expect {
          parsedData = JSON.parse(data);
        }.to_not raise_error
      end

      it "checks number of manifests" do
        output_dir = given_directory
        result = run_command(args: ["view", "--output-dir=#{output_dir}"])
        data = File.read(File.join(output_dir, 'inqlude-all.json'))
        parsedData = JSON.parse(data);

        settings = Settings.new
        handler = ManifestHandler.new settings
        handler.read_remote

        expect(handler.libraries.length).to eq parsedData.length
      end
    end
  end
end
