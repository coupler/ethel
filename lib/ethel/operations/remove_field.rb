module Ethel
  module Operations
    class RemoveField < Operation
      def initialize(name)
        super
        @name = name
      end

      def setup(dataset)
        super
        dataset.remove_field(@name)
      end

      register('remove_field', self)
    end
  end
end
