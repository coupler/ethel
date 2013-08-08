module Ethel
  class Writer
    include Register

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
