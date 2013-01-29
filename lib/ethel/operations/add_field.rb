module Ethel
  module Operations
    class AddField < Operation
      def initialize(field)
        super
        @field = field
      end

      def before_transform(source, target)
        super
        target.add_field(@field)
      end
    end
  end
end
