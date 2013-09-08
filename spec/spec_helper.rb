require File.expand_path('../../lib/inqlude', __FILE__)

def create_manifest name, version
  m = Hash.new
  m["name"] = name
  m["version"] = version
  m["description"] = "#{name} is a nice library."
  m
end
