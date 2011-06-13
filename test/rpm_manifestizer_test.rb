require File.expand_path('../test_helper', __FILE__)

class RpmManifestizerTest < Test::Unit::TestCase

  def test_is_library
    m = RpmManifestizer.new Settings.new
    assert m.is_library?( "libjson" )
    assert !m.is_library?( "kontact" )
  end

end
