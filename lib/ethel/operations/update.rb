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
          @value = args[0]
          @filter = block
        elsif block
          @value = block
        end
      end

      def transform(row)
        row = super(row)
        if @filter.nil? || @filter.call(row[@field.name])
          row[@field.name] = @value.is_a?(Proc) ? @value.call(row[@field.name]) : @value
        end
        row
      end
    end
  end
end
