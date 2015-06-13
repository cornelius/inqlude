require_relative "spec_helper"

include CliTester

describe "Command line interface" do
  describe "get_involved" do
    it "shows list of open issues" do
      result = run_command(args: ["get_involved"])
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match("github.com/cornelius/inqlude/issues")
      expect(result.stderr.empty?).to be(true)
    end
  end
end
