require_relative "spec_helper"

include CliTester

describe "Command line interface" do
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
end
