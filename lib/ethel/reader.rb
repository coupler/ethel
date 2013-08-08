module Ethel
  class Reader
    include Register

    def each_row
      raise NotImplementedError
    end

    def read(dataset)
      raise NotImplementedError
    end
  end
end
