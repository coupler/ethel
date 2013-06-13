module Ethel
  module Operations
    # NOTE: Should this include a way to update a whole row, or does that
    # belong in a different operation? If the latter, should this operation be
    # renamed to avoid confusion with the `UPDATE` SQL statement? I'm inclined
    # to limit the scope of most operations and group all custom stuff into a
    # "do whatever" operation.
    class Update < Operation
      def initialize(name, *args, &block)
        super
        @name = name
        if args.length > 0
          @value = args[0]
          @filter = block
          @static = true
        elsif block
          @value = block
        end
      end

      def setup(dataset)
        super
        @field = dataset.field(@name)
        if @static && !@value.nil?
          value_type = Util.type_of(@value)
          if !(@field.type == :blob && value_type == :string) && value_type != @field.type
            raise InvalidFieldType, "expected value to be of type #{@field.type}, but was #{value_type}"
          end
        end
      end

      def transform(row)
        row = super(row)
        if @filter.nil? || @filter.call(row[@name])
          new_value = @static ? @value : @value.call(row[@name])
          if !new_value.nil? && Util.type_of(new_value) != @field.type
            raise InvalidFieldType
          end
          row[@name] = new_value
        end
        row
      end

      register('update', self)
    end
  end
end
