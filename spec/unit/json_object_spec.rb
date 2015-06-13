require_relative "spec_helper.rb"

class MyObject < JsonObject
  attribute :name
  attribute :version

  attribute :licenses

  attribute :urls do
    attribute :homepage
    attribute :download
  end

  attribute :custom
end

class MyDerivedObject < MyObject
end

class MyOtherObject < JsonObject
  attribute :hello
end

describe JsonObject do
  describe "construction" do
    it "works when two JsonObjects are defined" do
      object = MyOtherObject.new

      object.hello = "world"

      expect(object.hello).to eq "world"
    end

    it "defines internal classes" do
      object = MyObject.new

      expect(object.urls).to be_a MyObject::Urls
    end

    it "inherits keys from super class" do
      expect(MyDerivedObject.all_keys).to include(:name)
    end

    it "can instantiate sub class" do
      object = MyDerivedObject.new

      object.name = "Sub Jason"
      expect(object.name).to eq "Sub Jason"
    end
  end

  describe "attributes" do
    it "defines accessors" do
      object = MyObject.new

      object.name = "Jason"
      expect(object.name).to eq "Jason"

      object.version = "1.2.3"
      expect(object.version).to eq "1.2.3"

      object.licenses = ["GPLv2", "LGPLv2.1"]
      expect(object.licenses).to eq ["GPLv2", "LGPLv2.1"]

      object.urls.homepage = "http://example.com"
      expect(object.urls.homepage).to eq "http://example.com"
    end

    it "returns validity of objects" do
      object = MyObject.new

      expect(object.valid?).to be false
      expect(object.urls.valid?).to be false

      object.name = "Jason"

      expect(object.valid?).to be true
      expect(object.urls.valid?).to be false

      object.urls.homepage = "http://example.com"

      expect(object.valid?).to be true
      expect(object.urls.valid?).to be true
    end

    it "returns nil for unset attribute" do
      json = <<EOT
{
  "name": "Jason"
}
EOT
      object = MyDerivedObject.new.from_json(json)

      expect(object.name).to eq "Jason"
      expect(object.version).to be nil
    end

    it "raises exception for non-existing attribute" do
      object = MyObject.new

      expect {
        object.invalid_attribute
      }.to raise_error(NoMethodError)
    end
  end

  describe "JSON" do
    before(:all) do
      @json = <<EOT
{
  "name": "Jason",
  "version": "1.2.3",
  "licenses": [
    "GPLv2",
    "LGPLv2.1"
  ],
  "urls": {
    "homepage": "http://example.com",
    "download": "http://example.org/download"
  }
}
EOT
      @json.chomp!
    end

    describe "reads" do
      it "from hash" do
        hash = JSON(@json)

        object = MyObject.new.from_hash(hash)
        expect(object.class).to be MyObject
        expect(object.name).to eq "Jason"
        expect(object.urls.class).to eq MyObject::Urls
        expect(object.urls.homepage).to eq "http://example.com"
      end

      it "from JSON" do
        object = MyObject.new.from_json(@json)

        expect(object.class).to be MyObject
        expect(object.name).to eq "Jason"
        expect(object.version).to eq "1.2.3"
        expect(object.licenses).to eq ["GPLv2", "LGPLv2.1"]
        expect(object.urls.homepage).to eq "http://example.com"
        expect(object.urls.download).to eq "http://example.org/download"
      end

      it "skips schema id" do
        json = <<EOT
{
  "$schema": "abc:xyz",
  "name": "Jason"
}
EOT
        object = MyObject.new.from_json(json)

        expect(object.name).to eq "Jason"
      end

      it "hashes as values" do
        json = <<EOT
{
  "$schema": "http://example.com/schema/myobject-v1#",
  "name": "Jason",
  "custom": {
    "one": "1",
    "two": "2"
  }
}
EOT
        object = MyObject.new.from_json(json)

        expect(object.name).to eq "Jason"
        expect(object.custom).to eq({ "one" => "1", "two" => "2" })
      end

      it "raises exception on unexpected attribute" do
        json = <<EOT
{
  "name": "Jason",
  "invalid_attribute": "42"
}
EOT
        object = MyObject.new
        expect {
          object.from_json(json)
        }.to raise_error(NoMethodError)
      end
    end

    describe "writes" do
      it "to hash" do
        object = MyObject.new
        object.name = "Jason"
        object.version = "1.2.3"
        object.licenses = ["GPLv2", "LGPLv2.1"]
        object.urls.homepage = "http://example.com"
        object.urls.download = "http://example.org/download"

        expected_hash = {
          :name => "Jason",
          :version => "1.2.3",
          :licenses => ["GPLv2", "LGPLv2.1"],
          :urls => {
            :homepage => "http://example.com",
            :download => "http://example.org/download"
          }
        }

        expect(object.to_hash).to eq expected_hash
      end

      it "to JSON" do
        expected_json = @json

        object = MyObject.new
        object.name = "Jason"
        object.version = "1.2.3"
        object.licenses = ["GPLv2", "LGPLv2.1"]
        object.urls.homepage = "http://example.com"
        object.urls.download = "http://example.org/download"

        expect(object.to_json).to eq expected_json
      end

      it "only attributes which have a value" do
        object = MyObject.new
        object.name = "Jason"

        expected_json = <<EOT
{
  "name": "Jason"
}
EOT
        expected_json.chomp!

        expect(object.to_json).to eq expected_json
      end

      it "schema id" do
        expected_json = <<EOT
{
  "$schema": "http://example.com/schema/myobject-v1#",
  "name": "Jason"
}
EOT
        expected_json.chomp!

        object = MyObject.new
        object.schema_id = "http://example.com/schema/myobject-v1#"
        object.name = "Jason"

        expect(object.to_json).to eq expected_json
      end

      it "hashes as values" do
        json = <<EOT
{
  "name": "Jason",
  "custom": {
    "one": "1",
    "two": "2"
  }
}
EOT

        object = MyObject.new.from_json(json)

        expect(object.to_json).to eq json.chomp
      end
    end
  end
end
