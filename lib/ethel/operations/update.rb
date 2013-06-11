module Ethel
  module Operations
    # NOTE: Should this include a way to update a whole row, or does that
    # belong in a different operation? If the latter, should this operation be
    # renamed to avoid confusion with the `UPDATE` SQL statement? I'm inclined
    # to limit the scope of most operations and group all custom stuff into a
    # "do whatever" operation.
    class Update < Operation
      def initialize(field, *args, &block)
        super
        @field = field
        if args.length > 0
          if !args[0].nil?
            value_type = Util.type_of(args[0])
            if !(@field.type == :blob && value_type == :string) && value_type != @field.type
              raise InvalidFieldType
            end
          end
          @value = args[0]
          @filter = block
        elsif block
          @value = block
        end
        add_child_operation(AddField.new(@field))
      end

      def transform(row)
        row = super(row)
        if @filter.nil? || @filter.call(row[@field.name])
          new_value = @value.is_a?(Proc) ? @value.call(row[@field.name]) : @value
          if !new_value.nil? && Util.type_of(new_value) != @field.type
            raise InvalidFieldType
          end
          row[@field.name] = new_value
        end
        row
      end
    end
  end
end
