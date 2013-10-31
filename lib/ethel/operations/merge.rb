module Ethel
  module Operations
    class Merge < Operation
      def initialize(reader, left_fields, right_fields = left_fields)
        super
        @reader = reader
        @left_fields = left_fields.is_a?(Array) ? left_fields : [left_fields]
        @right_fields = right_fields.is_a?(Array) ? right_fields : [right_fields]
        if @left_fields.length != @right_fields.length
          raise ArgumentError, "left and right fields must be the same length"
        end
      end

      def setup(dataset)
        super

        other = Dataset.new
        @reader.read(other)
        other.each_field do |field|
          if !@right_fields.include?(field.name)
            dataset.add_field(field)
          end
        end
      end

      def transform(row)
        row = super

        target_keys = row.values_at(*@left_fields)
        @reader.each_row do |merge_row|
          keys = merge_row.values_at(*@right_fields)
          if keys == target_keys
            row = row.merge(merge_row.reject { |k, v| @right_fields.include?(k) })
            break
          end
        end

        row
      end

      register('merge', self)
    end
  end
end
