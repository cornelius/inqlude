class JsonObject

  def self.attribute(name, &block)
    define_method("#{name}=") do |value|
      @values[name] = value
      @valid[name] = true
    end

    @keys ||= Hash.new

    if block_given?
      define_method("#{name}") do
        return @values[name]
      end

      nested_class = self.const_set(name.to_s.capitalize, Class.new(JsonObject))
      nested_class.class_exec(&block)
      type = nested_class
    else
      define_method("#{name}") do
        if @valid[name]
          return @values[name]
        else
          return nil
        end
      end

      type = nil
    end
    @keys[name] = type
  end

  def self.keys
    @keys
  end

  def self.all_keys
    keys = Hash.new
    klass = self
    while(klass != JsonObject) do
      if klass.keys
        keys.merge!(klass.keys)
      end
      klass = klass.superclass
    end
    keys
  end

  attr_accessor :schema_id

  def initialize
    @values = Hash.new
    self.class.all_keys.each do |key,value|
      if value
        @values[key] = value.new
      end
    end
    @valid = Hash.new
  end

  def valid?
    !@valid.empty?
  end

  def from_hash(hash)
    hash.each do |key, value|
      next if key == "$schema"
      type = self.class.all_keys[key.to_sym]
      value = hash[key]
      if type
        nested_object = send("#{key}")
        nested_object.from_hash(value)
      else
        send("#{key}=", value)
      end
    end
    self
  end

  def from_json(json_string)
    from_hash(JSON(json_string))
  end

  def to_hash
    hash = Hash.new
    if schema_id
      hash["$schema"] = schema_id
    end
    self.class.all_keys.each do |attribute,type|
      value = @values[attribute]
      if type && value.valid?
        hash[attribute] = value.to_hash
      elsif @valid[attribute]
        hash[attribute] = value
      end
    end
    hash
  end

  def to_json
    JSON.pretty_generate(to_hash)
  end

end
