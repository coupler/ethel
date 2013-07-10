module Ethel
  module Operations
    class Merge < Operation
      def initialize(reader, left_name, right_name = left_name)
        super
        @reader = reader
        @left_name = left_name
        @right_name = right_name
      end

      def setup(dataset)
        super

        other = Dataset.new
        @reader.read(other)
        other.each_field do |field|
          if field.name != @right_name
            dataset.add_field(field)
          end
        end
      end

      def transform(row)
        row = super

        target = row[@left_name]
        @reader.each_row do |merge_row|
          if merge_row[@right_name] == target
            row = row.merge(merge_row.reject { |k, v| k == @right_name })
            break
          end
        end

        row
      end

      register('merge', self)
    end
  end
end
