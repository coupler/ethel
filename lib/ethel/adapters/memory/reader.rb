module Ethel
  module Adapters
    module Memory
      class Reader < ::Ethel::Reader
        def initialize(options)
          @data = options[:data]
          @field_types = options[:field_types]
        end

        def read(dataset)
          if @field_types
            field_types = @field_types
            autodiscover = false
          else
            field_types = {}
            autodiscover = true
          end

          @data.to_enum.with_index do |row, i|
            if i == 0 && autodiscover
              row.each do |(name, val)|
                field_types[name] = Util.type_of(val)
              end
            else
              row.each do |(name, val)|
                if !field_types.has_key?(name)
                  raise InvalidFieldName, "row #{i}: #{name} is not a valid field"
                end
                next if val.nil?

                type = Util.type_of(val)
                if field_types[name].nil? && autodiscover
                  if type
                    field_types[name] = type
                  end
                elsif type != field_types[name]
                  raise InvalidFieldType, "row #{i}: expected #{name} to be of type #{field_types[name].inspect}, but was #{type.inspect}"
                end
              end
            end
          end

          field_types.each_pair do |name, type|
            if autodiscover && type.nil?
              raise InvalidFieldType, "column #{name.inspect} had only nil values, could not determine type"
            end
            field = Field.new(name, :type => type)
            dataset.add_field(field)
          end
        end

        def each_row(&block)
          @data.each(&block)
        end

        ::Ethel::Reader.register('memory', self)
      end
    end
  end
end
