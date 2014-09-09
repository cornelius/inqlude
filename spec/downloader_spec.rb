require File.expand_path('../spec_helper', __FILE__)

include GivenFilesystemSpecHelpers

describe Downloader do

  use_given_filesystem

  include_context "manifest_files"
  
  it "downloads source tarball" do
    mh = ManifestHandler.new(settings)
    mh.read_remote

    output = double
    expect(output).to receive(:puts).at_least(:once)

    downloader = Downloader.new(mh, output)

    expect(downloader).to receive(:read_from_url).and_return("dummy tarball")

    path = given_directory

    downloader.download("awesomelib", path)

    tarball_path = File.join(path, "awesomelib-0.2.0.tar.gz")

    expect(File.exists?(tarball_path)).to be true
    expect(File.read(tarball_path)).to eq "dummy tarball"
  end

end
