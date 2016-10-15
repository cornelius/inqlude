require_relative "spec_helper"

class DistroUnknown
  def name
    "<unknown distro>"
  end

  def version
    "<unknown version>"
  end
end

describe CliController do
  let(:distro) {DistroUnknown.new}

  describe ".print_versions" do
    it "prints versions" do
      expected_output = <<EOT
Inqlude: #{Inqlude::VERSION}
Qt: 4.8.6
OS: <unknown distro> <unknown version>
EOT
      expect {
        CliController.print_versions(distro)
      }.to output(expected_output).to_stdout
    end
  end
end
