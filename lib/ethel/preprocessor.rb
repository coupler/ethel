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

    def valid?
      @errors.clear
      validate
      @errors.empty?
    end

    def each_error(&block)
      @errors.each(&block)
    end

    protected

    def validate
    end
  end
end
