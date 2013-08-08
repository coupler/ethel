module Ethel
  module Readers
    class Memory < Reader
      def initialize(options)
        @data = options[:data]
      end

      def read(dataset)
        fields = {}
        @data.to_enum.with_index do |row, i|
          if i == 0
            row.each do |(name, val)|
              fields[name] = Util.type_of(val)
            end
          else
            row.each do |(name, val)|
              if !fields.has_key?(name)
                raise InvalidFieldName, "row #{i}: #{name} is not a valid field"
              end

              type = Util.type_of(val)
              if type != fields[name]
                raise InvalidFieldType, "row #{i}: expected #{name} to be of type #{fields[name]}, but was #{type}"
              end
            end
          end
        end
        fields.each_pair do |name, type|
          field = Field.new(name, :type => type)
          dataset.add_field(field)
        end
      end

      def each_row(&block)
        @data.each(&block)
      end

      Reader.register('memory', self)
    end
  end
end
