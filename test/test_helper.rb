require File.expand_path('../../lib/inqlude',__FILE__)

require 'test/unit'

def create_manifest name, version
  m = Hash.new
  m["name"] = name
  m["version"] = version
  m["description"] = "#{name} is a nice library."
  m
end
