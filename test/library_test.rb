require File.expand_path('../test_helper', __FILE__)

class LibraryTest < Test::Unit::TestCase

  def test_versions
    versions = [ "1.0", "2.0" ]

    manifests = Array.new
    versions.each do |version|
      manifests.push create_manifest "mylib", version
    end

    library = Library.new
    library.manifests = manifests

    assert_equal versions, library.versions
  end

end
