module Ethel
  module Operations
    class ShiftDate < Operation
      def initialize(name, key_name, options = {})
        super
        @name = name
        @key_name = key_name
        @random =
          if options.has_key?(:seed)
            Random.new(options[:seed])
          else
            Random.new
          end
        @range = 1..364
        @shift_amounts = {}
      end

      def setup(dataset)
        super

        # don't do anything except validate dataset
        field = dataset.field(@name, true)
        if field.type != :date
          raise "expected field '#{@name}' type to be :date, but got #{field.type}"
        end

        # check primary key
        dataset.field(@key_name, true)
      end

      def transform(row)
        row = super(row.dup)
        key = row[@key_name]
        if key.nil?
          raise "Value for key field '#{@key_name}' is nil"
        end

        value = row[@name]
        if !value.nil?
          if !value.is_a?(Date)
            raise "Value for field '#{@name}' is not a date: #{value.inspect}"
          end

          @shift_amounts[key] ||= @range.min + @random.rand(@range.max)
          row[@name] = value + @shift_amounts[key]
        end

        row
      end

      register('shift_date', self)
    end
  end
end
