module Ethel
  # Reader is the main class for reading in data. Each adapter reader (CSV,
  # memory, etc) registers itself with the Reader class via the
  # Register#register method.
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
