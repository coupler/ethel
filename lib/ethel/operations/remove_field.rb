module Ethel
  module Operations
    class RemoveField < Operation
      def initialize(field)
        super
        @field = field
      end

      def setup(dataset)
        super
        dataset.remove_field(@field.name)
      end
    end
  end
end
