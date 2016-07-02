require_relative "spec_helper"

include CliTester
include GivenFilesystemSpecHelpers

describe "Command line interface" do
  describe "shows error" do
    it "when command does not exist" do
      expect(run_command(args: ["abc"])).to exit_with_success("", /abc/)
    end

    it "when global option does not exist" do
      expect(run_command(args: ["--abc"])).to exit_with_success("", /--abc/)
    end

    it "when command option does not exist" do
      expect(run_command(args: ["list", "--abc"])).to exit_with_success("", /--abc/)
    end
  end

  describe "global options" do
    use_given_filesystem

    it "recognizes --offline option" do
      dir = given_directory_from_data("manifests")

      # This doesn't make much sense to a user, but that's what it is right now.
      # It will go away when we switched to GLI
      expected_stderr = <<-EOT
ERROR: "inqlude global" was called with arguments ["list"]
Usage: "inqlude global"
      EOT

      expect(run_command(args: ["--offline", "list", "--manifest_dir=#{dir}"]))
        .to exit_with_success("", expected_stderr)
    end
  end
end
