require_relative "spec_helper"

require_relative "cli_tester.rb"

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem

  describe "help" do
    it "shows help when run with no args" do
      result = run_command
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Commands:/)
      expect(result.stderr.empty?).to be(true)
    end

    it "shows help when run with help command" do
      result = run_command(args: ["help"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Commands:/)
      expect(result.stderr.empty?).to be(true)
    end

    it "shows help when run with --help option" do
      result = run_command(args: ["--help"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Commands:/)
      expect(result.stderr.empty?).to be(true)
    end

    it "shows help for command" do
      result = run_command(args: ["help", "list"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/inqlude list/)
      expect(result.stderr.empty?).to be(true)
    end
  end

  describe "errors" do
    it "fails with unknown option" do
      result = run_command(args: ["--xxx"])
      expect(result.exit_code).to eq(0)
      expect(result.stderr).to match(/Unknown/)
    end
  end

  describe "list" do
    it "lists libraries" do

      dir = given_directory do
        given_directory_from_data("awesomelib")
        given_directory_from_data("newlib")
      end

      result = run_command(args: ["list", "--remote", "--offline",
        "--manifest_dir=#{dir}"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to eq("awesomelib (0.2.0)\n")
      expect(result.stderr.empty?).to be(true)
    end
  end
end
