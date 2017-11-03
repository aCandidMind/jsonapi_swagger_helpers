module JsonapiSwaggerHelpers
  class Configuration
    def type_mapping
      @type_mapping ||= {
        string: [String],
        integer: [Integer],
        number: [Float],
        boolean: [TrueClass, FalseClass],
        object: [Hash]
      }
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
        @type_mapping[:integer] << Bignum
      end
      @type_mapping
    end
  end
end
