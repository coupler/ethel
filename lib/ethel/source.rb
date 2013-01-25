module Ethel
  class Source
    include Enumerable

    def schema
      raise NotImplementedError
    end

    def each
      raise NotImplementedError
    end

    def field_names
      schema.collect(&:first)
    end

    def fields
      @fields ||= schema.inject({}) do |hash, (name, options)|
        hash[name] = Field.new(name, options)
        hash
      end
    end

    def all
      to_a
    end
  end
end

require 'ethel/sources/csv'
