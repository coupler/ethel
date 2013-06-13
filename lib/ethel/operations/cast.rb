module Ethel
  module Operations
    class Cast < Operation
      def initialize(name, new_type)
        super
        @name = name
        @new_type = new_type
      end

      def setup(dataset)
        super
        new_field = Field.new(@name, :type => @new_type)
        dataset.alter_field(@name, new_field)
      end

      def transform(row)
        row = super(row)

        row[@name] =
          case @new_type
          when :integer
            row[@name].to_i
          when :string
            row[@name].to_s
          end

        row
      end

      register('cast', self)
    end
  end
end
