module Ethel
  class Writer
    @@writers = {}
    def self.register(name, klass)
      @@writers[name] = klass
    end

    def self.[](name)
      @@writers[name]
    end

    def prepare(dataset)
    end

    def add_row(*args)
      raise NotImplementedError
    end

    def flush
    end

    def data
      nil
    end
  end
end

require 'ethel/writers/csv'
require 'ethel/writers/memory'
