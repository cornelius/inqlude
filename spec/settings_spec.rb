require File.expand_path('../spec_helper', __FILE__)

describe Settings do

  include GivenFilesystemSpecHelpers

  it "lets manifest path to be set" do
    s = Settings.new
    s.manifest_path = "abc/xyz"
    expect(s.manifest_path).to eq "abc/xyz"
  end

  it "has default xdg data path" do
    s = Settings.new
    expected_path = File.join(ENV["HOME"], ".local/share/inqlude")
    received_path = s.xdg_data_path.to_s
    expect(received_path).to eq expected_path
  end

  it "has default xdg cache path" do
    s = Settings.new
    expected_path = File.join(ENV["HOME"], ".cache/inqlude")
    received_path = s.xdg_cache_path.to_s
    expect(received_path).to eq expected_path
  end

  it "has default manifest path" do
    expect(Settings.new.manifest_path).to eq(
      File.join( ENV["HOME"], ".local/share/inqlude/manifests"))
  end


  context "fake HOME" do
    use_given_filesystem

    before(:each) do
      @old_home = ENV["HOME"]

      @home = given_directory
      ENV["HOME"] = @home
    end

    after(:each) do
      ENV["HOME"] = @old_home
    end

    it "creates manifest dir" do
      s = Settings.new

      expect(s.manifest_dir).to eq File.join(@home,
        ".local/share/inqlude/manifests")
      expect(File.exist?(s.manifest_dir)).to be true
    end

    it "creates cache dir" do
      s = Settings.new

      expect(s.cache_dir).to eq File.join(@home,
        ".cache/inqlude")
      expect(File.exist?(s.cache_dir)).to be true
    end
  end

end
