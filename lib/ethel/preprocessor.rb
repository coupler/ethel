module Ethel
  # A preprocessor is for making sure the input data is in the
  # correct format.
  class Preprocessor
    include Register

    attr_reader :options

    def initialize(options)
      @options = options
      @errors = []
    end

    def check
      true
    end

    def each_error(&block)
      @errors.each(&block)
    end
  end
end
