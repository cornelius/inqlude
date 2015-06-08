require_relative "spec_helper"

class CommandResult
  attr_accessor :stdout, :stderr, :exit_code
end

def run_command(args: "")
  cmd = "bin/inqlude"
  if args
    cmd += " " + args
  end
  result = CommandResult.new
  result.stdout = `#{cmd}`
  result.stderr = ""
  result.exit_code = 0
  result
end

describe "Command line interface" do
  include GivenFilesystemSpecHelpers

  use_given_filesystem(keep_files: true)

  describe "help" do
    it "shows help" do
      result = run_command
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Commands:/)
      expect(result.stderr.empty?).to be(true)
    end
  end

  describe "list" do
    it "lists libraries" do

      dir = given_directory do
        given_directory_from_data("awesomelib")
        given_directory_from_data("newlib")
      end

      result = run_command(args: "list --remote --offline --manifest_dir=#{dir}")
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to eq("awesomelib (0.2.0)\n")
      expect(result.stderr.empty?).to be(true)
    end
  end
end
