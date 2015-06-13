require 'given_filesystem/spec_helpers'

require_relative "../../lib/inqlude"

def test_data_path file_name
  File.expand_path(File.join('../../data/', file_name), __FILE__)
end

def create_manifest name, release_date, version
  m = ManifestRelease.new
  m.name = name
  m.version = version
  m.release_date = release_date
  m.description = "#{name} is a nice library."
  m
end

def create_generic_manifest name
  m = ManifestGeneric.new
  m.name = name
  m.description = "#{name} is a nice library."
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
