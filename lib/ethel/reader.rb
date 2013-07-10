module Ethel
  class Reader
    @@readers = {}
    def self.register(name, klass)
      @@readers[name] = klass
    end

    def self.[](name)
      @@readers[name]
    end

    def each_row
      raise NotImplementedError
    end

    def read(dataset)
      raise NotImplementedError
    end
  end
end

require 'ethel/readers/memory'
require 'ethel/readers/csv'
