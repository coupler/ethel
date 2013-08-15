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

    def run(options = nil)
      if !@errors.empty?
        # make sure errors are resolved
        if @errors.any? { |error| error.choice.nil? }
          raise "Cannot run preprocessor with unresolved errors"
        end

        process(options)
      end
    end

    protected

    def validate
    end

    def process(options = nil)
    end
  end
end
