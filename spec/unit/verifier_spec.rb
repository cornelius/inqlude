require File.expand_path('../spec_helper', __FILE__)

describe Verifier do

  include_context "manifest_files"

  describe Verifier::Result do
    it "defines result class" do
      expect(subject.valid?).to be true
      expect(subject.errors.class).to be Array
    end

    context "no errors" do
      before do
        subject.name = "abc"
      end

      it "is valid" do
        expect(subject.valid?).to be true
      end

      it "prints result" do
        expected_output = <<EOT
Verify manifest abc...ok
EOT

        expect {
          subject.print_result
        }.to output(expected_output).to_stdout
      end
    end

    context "one error" do
      before do
        subject.name = "abc"
        subject.errors.push("an error")
      end

      it "is invalid" do
        expect(subject.valid?).to be false
      end

      it "prints result" do
        expected_output = <<EOT
Verify manifest abc...error
  an error
EOT

        expect {
          subject.print_result
        }.to output(expected_output).to_stdout
      end
    end

    context "multiple errors" do
      before do
        subject.name = "abc"
        subject.errors.push("an error")
        subject.errors.push("another error")
      end

      it "is invalid" do
        expect(subject.valid?).to be false
      end

      it "prints result" do
        expected_output = <<EOT
Verify manifest abc...error
  an error
  another error
EOT

        expect {
          subject.print_result
        }.to output(expected_output).to_stdout
      end
    end

    context "one warning" do
      before do
        subject.name = "xyz"
        subject.warnings.push("a warning")
      end

      it "has warning" do
        expect(subject.has_warnings?).to be true
      end

      it "prints warning" do
        expected_output = <<EOT
Verify manifest xyz...ok
  a warning
EOT

        expect {
          subject.print_result
        }.to output(expected_output).to_stdout
      end
    end

    context "multiple warnings" do
      before do
        subject.name = "xyz"
        subject.warnings.push("a warning")
        subject.warnings.push("another warning")
      end

      it "has warning" do
        expect(subject.has_warnings?).to be true
      end

      it "prints warning" do
        expected_output = <<EOT
Verify manifest xyz...ok
  a warning
  another warning
EOT

        expect {
          subject.print_result
        }.to output(expected_output).to_stdout
      end
    end
  end

  it "verifies read manifests" do
    handler = ManifestHandler.new settings
    handler.read_remote

    verifier = Verifier.new settings
    expect(verifier.verify( handler.manifest("awesomelib") ).class).to be Verifier::Result
    expect(verifier.verify( handler.manifest("awesomelib") ).valid?).to be true
  end

  it "detects incomplete manifest" do
    verifier = Verifier.new settings

    manifest = ManifestRelease.new
    expect(verifier.verify( manifest ).valid?).to be false
  end

  it "detects invalid entries" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    expect(verifier.verify(manifest).valid?).to be true

    expect{ manifest.invalidentry }.to raise_error(NoMethodError)
    expect{ manifest["invalidentry"] }.to raise_error(NoMethodError)
  end

  it "detects name mismatch" do
    handler = ManifestHandler.new settings
    handler.read_remote
    verifier = Verifier.new settings

    manifest = handler.manifest("awesomelib")
    expect(verifier.verify(manifest).valid?).to be true

    manifest.filename = "wrongname"

    result = verifier.verify(manifest)

    expect(result.valid?).to be false
    expect(result.errors.first).to eq "Expected file name: awesomelib.2013-09-08.manifest"
  end

  context "one invalid topic" do
    it "detects invalid topics" do
      handler = ManifestHandler.new settings
      handler.read_remote
      verifier = Verifier.new settings

      manifest = handler.manifest("awesomelib")
      expect(verifier.verify(manifest).valid?).to be true

      manifest.topics = ["Invalid"]

      result = verifier.verify(manifest)

      expect(result.valid?).to be false
      expect(result.errors).to include "Invalid topics: Invalid. Valid topics are API,Artwork,Bindings,Communication,Data,Desktop,Development,Graphics,Logging,Mobile,Multimedia,Printing,QML,Scripting,Security,Text,Web,Widgets"
    end
  end

  context "multiple invalid topics" do
    it "detects invalid topics" do
      handler = ManifestHandler.new settings
      handler.read_remote
      verifier = Verifier.new settings

      manifest = handler.manifest("awesomelib")
      expect(verifier.verify(manifest).valid?).to be true

      manifest.topics = ["API","Invalid1","Invalid2"]

      result = verifier.verify(manifest)

      expect(result.valid?).to be false
      expect(result.errors).to include "Invalid topics: Invalid1,Invalid2. Valid topics are API,Artwork,Bindings,Communication,Data,Desktop,Development,Graphics,Logging,Mobile,Multimedia,Printing,QML,Scripting,Security,Text,Web,Widgets"
    end
  end

  it "verifies release manifest file" do
    filename = File.join settings.manifest_path, awesomelib_manifest_file

    verifier = Verifier.new settings

    expect( verifier.verify_file( filename ).valid? ).to be true
  end

  it "verifies generic manifest file" do
    filename = File.join settings.manifest_path, newlib_manifest_file

    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be true
  end

  it "verifies proprietary release manifest file" do
    filename = File.join settings.manifest_path, proprietarylib_manifest_file

    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be true
  end

  it "verifies invalid schema id" do
    filename = test_data_path("invalid-schema.manifest")

    verifier = Verifier.new settings

    verification_result = verifier.verify_file( filename )
    expect( verification_result.valid? ).to be false
  end

  it "verifies schema" do
    manifest = ManifestRelease.new
    manifest.name = "mylib"
    manifest.release_date = "2013-02-28"
    manifest.filename = "mylib.2013-02-28.manifest"
    manifest.libraryname = "mylib"

    verifier = Verifier.new settings

    errors = verifier.verify(manifest).errors

    expect( errors.class ).to be Array
    expect(errors[0]).to match /^Schema validation error/
    expect(errors.count).to eq 8
  end

end
