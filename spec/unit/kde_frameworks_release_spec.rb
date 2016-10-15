require File.expand_path('../spec_helper', __FILE__)

describe KdeFrameworksRelease do
  include GivenFilesystemSpecHelpers
  use_given_filesystem

  context "given KDE generic manifests" do
    before(:each) do
      @manifest_dir = given_directory do
        given_directory("karchive") do
          given_file("karchive.manifest", :from => "karchive-generic.manifest")
        end
        given_directory("kservice") do
          given_file("kservice.manifest", :from => "kservice-generic.manifest")
        end
        given_directory("newlib") do
          given_file("newlib.manifest", :from => "manifests/newlib/newlib.manifest")
        end
      end

      s = Settings.new
      s.manifest_path = @manifest_dir
      s.offline = true
      @manifest_handler = ManifestHandler.new s
    end

    it "reads generic manifests" do
      k = KdeFrameworksRelease.new @manifest_handler
      k.read_generic_manifests

      expect(k.generic_manifests.count).to eq 2
      expect(k.generic_manifests[0].name).to eq "karchive"
      expect(k.generic_manifests[1].name).to eq "kservice"
    end

    it "writes release manifests" do
      k = KdeFrameworksRelease.new @manifest_handler
      k.read_generic_manifests

      k.write_release_manifests("2014-02-01", "4.9.90")

      manifest_path = File.join(@manifest_dir,"karchive/karchive.2014-02-01.manifest")
      expect(File.exists? manifest_path).to be true

      manifest_path = File.join(@manifest_dir,"kservice/kservice.2014-02-01.manifest")
      expect(File.exists? manifest_path).to be true

      manifest = Manifest.parse_file(manifest_path)
      expect(manifest.class).to be ManifestRelease
      expect(manifest.name).to eq "kservice"
      expect(manifest.version).to eq "4.9.90"
      expect(manifest.release_date).to eq "2014-02-01"
    end
  end

  it "creates release manifest from generic manifest" do
    generic_manifest = Manifest.parse_file(given_file("karchive-generic.manifest"))
    date = "2014-11-06"
    version = "5.4.0"
    release_manifest = KdeFrameworksRelease.create_release_manifest(
      generic_manifest, date, version)
    expected_json = File.read(given_file("karchive-release-5.4.manifest"))
    expected_json.chomp! # Remove newline added by File.read
    expect(release_manifest.to_json).to eq expected_json
  end

  it "strips patch release" do
    expect(KdeFrameworksRelease.strip_patch_release("5.4.0")).to eq "5.4"
  end
end
