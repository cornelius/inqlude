require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem(keep_files: true)

  describe "shows error" do
    it "when command does not exist" do
      result = run_command(args: ["abc"])
      expect(result.exit_code).to eq(0)
      expect(result.stderr).to match("abc")
      expect(result.stdout.empty?).to be(true)
    end

    it "when global option does not exist" do
      result = run_command(args: ["--abc"])
      expect(result.exit_code).to eq(0)
      expect(result.stderr).to match("--abc")
      expect(result.stdout.empty?).to be(true)
    end

    it "when command option does not exist" do
      result = run_command(args: ["list", "--abc"])
      expect(result.exit_code).to eq(0)
      expect(result.stderr).to match("--abc")
      expect(result.stdout.empty?).to be(true)
    end
  end

  describe "help" do
    it "shows general help" do
      result = run_command
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Commands:/)
      expect(result.stderr.empty?).to be(true)
    end

    it "shows help for command" do
      result = run_command(args: ["help", "list"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match("inqlude list")
      expect(result.stderr.empty?).to be(true)
    end
  end

  describe "get_involved" do
    it "shows list of open issues" do
      result = run_command(args: ["get_involved"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match("github.com/cornelius/inqlude/issues")
      expect(result.stderr.empty?).to be(true)
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
