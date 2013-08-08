module Ethel
  class Error
    attr_reader :message, :choice, :info

    def initialize(message, recoverable, info = {})
      @message = message
      @recoverable = recoverable
      @info = info
    end

    def recoverable?
      @recoverable
    end

    def each_choice
      choices.each do |choice|
        if choice.is_a?(Hash)
          name = choice.keys[0]
          args = choice[name]
        else
          name = choice
          args = {}
        end
        yield name, args
      end
    end

    def choose(val, args = {})
      choice = choices.find do |c|
        val == (c.is_a?(Hash) ? c.keys[0] : c)
      end

      if choice.nil?
        raise InvalidChoice, "#{val.inspect} is not a valid response"
      end

      if !args.is_a?(Hash)
        raise ArgumentError, "expected args to be a Hash, but was a #{args.class}"
      end

      params = choice.is_a?(Hash) ? choice.values[0] : {}
      args = params.inject({}) do |hsh, (name, type)|
        if !args.has_key?(name)
          raise InvalidChoice, "missing #{name.inspect} argument for choice #{choice.inspect}"
        else
          actual = Util.type_of(args[name])
          if actual != type
            raise InvalidChoice, "expected #{name.inspect} argument to be of type #{type}, but was #{actual}"
          end
        end
        hsh[name] = args[name]
        hsh
      end
      @choice = args.empty? ? val : [val, args]
    end

    protected

    def choices
      []
    end
  end
end
