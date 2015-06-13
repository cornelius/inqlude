require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem

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
