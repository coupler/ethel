module Ethel
  module Readers
    class Memory < Reader
      def initialize(data)
        @data = data
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
          dataset.add_field(Field.new(name, type))
        end
      end

      def each_row(&block)
        @data.each(&block)
      end
    end
  end
end
