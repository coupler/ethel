module Ethel
  module Operations
    class Select < Operation
      def initialize(*fields)
        super
        @fields = fields
      end

      def setup(dataset)
        super

        remove = []
        dataset.each_field do |field|
          if @fields.detect { |f| f.name == field.name}.nil?
            remove << field.name
          end
        end
        remove.each do |name|
          dataset.remove_field(name)
        end
      end
    end
  end
end
