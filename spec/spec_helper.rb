require File.expand_path('../../lib/inqlude', __FILE__)
require File.expand_path('../given_filesystem', __FILE__)

def create_manifest name, version
  m = Hash.new
  m["name"] = name
  m["version"] = version
  m["description"] = "#{name} is a nice library."
  m
end

shared_context "manifest_files" do

  let(:settings) do
    s = Settings.new
    s.manifest_path = File.expand_path('spec/data/')
    s.offline = true
    s
  end

  let(:awesomelib_manifest_file) do
    "awesomelib/awesomelib.2013-09-08.manifest"
  end

  let(:newlib_manifest_file) do
    "newlib/newlib.manifest"
  end

  let(:proprietarylib_manifest_file) do
    "proprietarylib/proprietarylib.2013-12-22.manifest"
  end

end
