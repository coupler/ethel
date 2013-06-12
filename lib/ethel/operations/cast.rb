module Ethel
  module Operations
    class Cast < Operation
      def initialize(field, new_type)
        super
        @original_field = field
        @new_field = Field.new(@original_field.name, :type => new_type)
      end

      def setup(dataset)
        super
        dataset.alter_field(@original_field.name, @new_field)
      end

      def transform(row)
        row = super(row)

        row[@original_field.name] =
          case @new_field.type
          when :integer
            row[@original_field.name].to_i
          when :string
            row[@original_field.name].to_s
          end

        row
      end
    end
  end
end
