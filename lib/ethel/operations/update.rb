module Ethel
  module Operations
    class Update < Operation
      def initialize(*args, &block)
        super
        if args.length > 0
          @name = args[0]
          if args.length > 1
            @value = args[1]
            @filter = block
            @static = true
          elsif block
            @value = block
          end
        else
          @block = block
        end
      end

      def setup(dataset)
        super
        if @name
          @field = dataset.field(@name)
          if @static && !@value.nil?
            value_type = Util.type_of(@value)
            if !(@field.type == :blob && value_type == :string) && value_type != @field.type
              raise InvalidFieldType, "expected value to be of type #{@field.type}, but was #{value_type}"
            end
          end
        end
      end

      def transform(row)
        row = super(row)
        if @name
          if @filter.nil? || @filter.call(row)
            new_value = @static ? @value : @value.call(row)
            row[@name] = new_value
          end
        else
          # Update whole row
          @block.call(row)
        end
        row
      end

      register('update', self)
    end
  end
end
