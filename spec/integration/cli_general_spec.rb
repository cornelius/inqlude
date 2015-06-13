require_relative "spec_helper"

include CliTester

describe "Command line interface" do
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
end
