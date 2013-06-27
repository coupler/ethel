module Ethel
  module Operations
    class Merge < Operation
      def initialize(reader, name)
        super
        @reader = reader
        @name = name
      end

      def setup(dataset)
        super

        other = Dataset.new
        @reader.read(other)
        other.each_field do |field|
          if field.name != @name
            dataset.add_field(field)
          end
        end
      end

      def transform(row)
        row = super

        target = row[@name]
        @reader.each_row do |merge_row|
          if merge_row[@name] == target
            row = row.merge(merge_row)
            break
          end
        end

        row
      end

      register('merge', self)
    end
  end
end
