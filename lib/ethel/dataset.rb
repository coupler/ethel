module Ethel
  class Dataset
    def initialize
      @fields = {}
    end

    def add_field(field)
      if @fields.has_key?(field.name)
        raise InvalidFieldName
      end

      @fields[field.name] = field
    end

    def remove_field(name)
      if !@fields.has_key?(name)
        raise NonexistentField
      end

      @fields.delete(name)
    end

    def alter_field(name, new_field)
      if !@fields.has_key?(name)
        raise NonexistentField
      end

      if new_field.name != name
        remove_field(name)
        add_field(new_field)
      else
        @fields[name] = new_field
      end
    end

    def field(name)
      @fields[name]
    end

    def each_field(&block)
      @fields.each_value(&block)
    end
  end
end
