module Ethel
  module Operations
    class AddField < Operation
      def initialize(name, type)
        super
        @name = name
        @type = type
      end

      def setup(dataset)
        super
        dataset.add_field(Field.new(@name, :type => @type))
      end

      register('add_field', self)
    end
  end
end
