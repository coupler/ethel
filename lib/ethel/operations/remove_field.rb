module Ethel
  module Operations
    class RemoveField < Operation
      def initialize(name)
        super
        @name = name
      end

      def setup(dataset)
        perform_setup(dataset) do |dataset|
          dataset.remove_field(@name)
          dataset
        end
      end

      def transform(row)
        perform_transform(row) do |row|
          row.delete(@name)
          row
        end
      end

      register('remove_field', self)
    end
  end
end
