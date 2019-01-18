module Ethel
  module Operations
    class Cast < Operation
      def initialize(name, new_type)
        super
        @name = name
        @new_type = new_type
      end

      def setup(dataset)
        perform_setup(dataset) do |dataset|
          new_field = Field.new(@name, :type => @new_type)
          dataset.alter_field(@name, new_field)
          dataset
        end
      end

      def transform(row)
        perform_transform(row) do |row|
          row[@name] =
            case @new_type
            when :integer
              row[@name].to_i
            when :float
              row[@name].to_f
            when :string
              row[@name].to_s
            end
          row
        end
      end

      register('cast', self)
    end
  end
end
