module Ethel
  module Operations
    class Cast < Operation
      def initialize(name, new_type, options = {})
        super
        @name = name
        @new_type = new_type
        @options = options

        if new_type == :date && !options.has_key?(:format)
          raise ":format option must be specified when new_type is :date"
        end
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
          when :float
            row[@name].to_f
          when :string
            row[@name].to_s
          when :date
            Date.strptime(row[@name], @options[:format])
          end

        row
      end

      register('cast', self)
    end
  end
end
