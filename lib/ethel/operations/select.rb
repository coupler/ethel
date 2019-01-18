module Ethel
  module Operations
    class Select < Operation
      def initialize(*names)
        super
        @names = names
      end

      def setup(dataset)
        perform_setup(dataset) do |dataset|
          remove = []
          dataset.each_field do |field|
            if !@names.include?(field.name)
              remove << field.name
            end
          end
          remove.each do |name|
            dataset.remove_field(name)
          end
          dataset
        end
      end

      def transform(row)
        perform_transform(row) do |row|
          row.keep_if { |k, v| @names.include?(k) }
        end
      end

      register('select', self)
    end
  end
end
