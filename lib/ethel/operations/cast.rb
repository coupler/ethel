module Ethel
  module Operations
    class Cast < Operation
      def initialize(field, new_type)
        super
        @original_field = field
        @field_name = field.name
        @new_type = new_type
        @new_field = Field.new(@field_name, :type => @new_type)
        add_child_operation(AddField.new(@new_field))
      end

      def transform(row)
        row = super(row)

        row[@field_name] =
          case @new_type
          when :integer
            row[@field_name].to_i
          when :string
            row[@field_name].to_s
          end

        row
      end
    end
  end
end
