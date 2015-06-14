require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem(keep_files: true)

  describe "verify" do
    it "verifies single manifest" do
      dir = given_directory do
        given_directory_from_data("awesomelib")
      end

      result = run_command(args: ["verify",
        File.join(dir, "awesomelib", "awesomelib.2013-09-08.manifest")])
      expect(result).to exit_with_success("Verify manifest awesomelib.2013-09-08.manifest...ok\n")
    end

    it "verifies all manifests" do
      dir = given_directory do
        given_directory_from_data("awesomelib")
        given_directory_from_data("newlib")
      end

      result = run_command(args: ["verify", "--offline", "--manifest_dir=#{dir}"])
      expected_output = <<EOT
Verify manifest awesomelib.2013-09-08.manifest...ok
Verify manifest newlib.manifest...ok

2 manifests checked. 2 ok, 0 with error.
EOT
      expect(result).to exit_with_success(expected_output)
    end
  end
end
