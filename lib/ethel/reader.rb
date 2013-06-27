module Ethel
  class Reader
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
