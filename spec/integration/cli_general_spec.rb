require_relative "spec_helper"

include CliTester

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
end
