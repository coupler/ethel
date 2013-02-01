module Ethel
  class Target
    def add_field(*args)
      raise NotImplementedError
    end

    def prepare
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

require 'ethel/targets/csv'
