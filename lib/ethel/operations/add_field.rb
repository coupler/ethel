module Ethel
  module Operations
    class AddField < Operation
      def initialize(field)
        super
        @field = field
      end

      def setup(dataset)
        super
        dataset.add_field(@field)
      end
    end
  end
end
