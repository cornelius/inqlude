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
    context "with qmake installed" do
      before do
        ENV["PATH"] = stubs_path("qmake") + ":" + ENV["PATH"]
      end

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

    context "without qmake installed" do
      before do
        allow(CliController).to receive(:find_executable).with("qmake").and_return(false)
      end

      it "prints versions" do
        expected_output = <<EOT
Inqlude: #{Inqlude::VERSION}
Qt: not found
OS: <unknown distro> <unknown version>
EOT
        expect {
          CliController.print_versions(distro)
        }.to output(expected_output).to_stdout
      end
    end
  end
end
