module Ethel
  module Operations
    class Rename < Operation
      def initialize(name, new_name)
        super
        @name = name
        @new_name = new_name
      end

      def setup(dataset)
        super
        field = dataset.field(@name, true)
        new_field = Field.new(@new_name, :type => field.type)
        dataset.alter_field(@name, new_field)
      end

      def transform(row)
        new_row = super(row).dup
        new_row[@new_name] = new_row.delete(@name)
        new_row
      end

      register('rename', self)
    end
  end
end
