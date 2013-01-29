module Ethel
  module Operations
    class Copy < Operation
      def initialize(field)
        super
        add_child_operation(AddField.new(field))
      end
    end
  end
end
