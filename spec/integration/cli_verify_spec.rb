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

    it "verifies all manifests with syntax error" do
      dir = given_directory do
        given_directory_from_data("awesomelib")
        given_directory("newlib") do
          given_dummy_file("newlib.manifest")
        end
      end

      result = run_command(args: ["verify", "--offline", "--manifest_dir=#{dir}"])
      expect(result).to exit_with_error(1,//)
    end

    it "verifies all manifests with schema error" do
      dir = given_directory do
        given_directory_from_data("awesomelib")
        given_directory_from_data("broken")
      end

      result = run_command(args: ["verify", "--offline", "--manifest_dir=#{dir}"])
      expected_output = <<EOT
Verify manifest awesomelib.2013-09-08.manifest...ok
Verify manifest broken.manifest...error
  Expected file name: .manifest
  Schema validation error: The property '#/' did not contain a required property of 'name' in schema http://inqlude.org/schema/generic-manifest-v1#
  Schema validation error: The property '#/' did not contain a required property of 'summary' in schema http://inqlude.org/schema/generic-manifest-v1#
  Schema validation error: The property '#/' did not contain a required property of 'urls' in schema http://inqlude.org/schema/generic-manifest-v1#
  Schema validation error: The property '#/' did not contain a required property of 'licenses' in schema http://inqlude.org/schema/generic-manifest-v1#
  Schema validation error: The property '#/' did not contain a required property of 'description' in schema http://inqlude.org/schema/generic-manifest-v1#
  Schema validation error: The property '#/' did not contain a required property of 'platforms' in schema http://inqlude.org/schema/generic-manifest-v1#

2 manifests checked. 1 ok, 1 with error.

Errors:
  broken.manifest
    Expected file name: .manifest
    Schema validation error: The property '#/' did not contain a required property of 'name' in schema http://inqlude.org/schema/generic-manifest-v1#
    Schema validation error: The property '#/' did not contain a required property of 'summary' in schema http://inqlude.org/schema/generic-manifest-v1#
    Schema validation error: The property '#/' did not contain a required property of 'urls' in schema http://inqlude.org/schema/generic-manifest-v1#
    Schema validation error: The property '#/' did not contain a required property of 'licenses' in schema http://inqlude.org/schema/generic-manifest-v1#
    Schema validation error: The property '#/' did not contain a required property of 'description' in schema http://inqlude.org/schema/generic-manifest-v1#
    Schema validation error: The property '#/' did not contain a required property of 'platforms' in schema http://inqlude.org/schema/generic-manifest-v1#
EOT
      expect(result).to exit_with_error(1,"",expected_output)
    end
  end
end
