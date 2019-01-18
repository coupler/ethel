module Ethel
  module Operations
    class AddField < Operation
      def initialize(name, type)
        super
        @name = name
        @type = type
      end

      def setup(dataset)
        perform_setup(dataset) do |dataset|
          dataset.add_field(Field.new(@name, :type => @type))
          dataset
        end
      end

      def transform(row)
        perform_transform(row) do |row|
          row[@name] = nil
          row
        end
      end

      register('add_field', self)
    end
  end
end
