module Ethel
  module Operations
    class Select < Operation
      def initialize(*names)
        super
        @names = names
      end

      def setup(dataset)
        super

        remove = []
        dataset.each_field do |field|
          if @names.index(field.name).nil?
            remove << field.name
          end
        end
        remove.each do |name|
          dataset.remove_field(name)
        end
      end

      register('select', self)
    end
  end
end
