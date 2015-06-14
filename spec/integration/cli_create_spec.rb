require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem

  describe "create" do
    it "creates new manifest" do

      dir = given_directory

      result = run_command(args: ["create", "--offline",
        "--manifest_dir=#{dir}", "newlib", "42.1", "2015-06-13"],
        working_directory: dir)
      expect(result).to exit_with_success("")

      expect(File.exist?(File.join(dir, "newlib", "newlib.2015-06-13.manifest"))).
        to be(true)
    end
  end
end
