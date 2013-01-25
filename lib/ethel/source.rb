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

    def all
      to_a
    end
  end
end

require 'ethel/sources/csv'
