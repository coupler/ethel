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

    def field(name, assert = false)
      field = @fields[name]
      if assert && field.nil?
        raise NonexistentField, "field '#{name}' doesn't exist"
      end
      field
    end

    def each_field(&block)
      @fields.each_value(&block)
    end

    def validate_row(row)
      keys = row.keys
      missing = nil
      invalid = nil
      each_field do |field|
        if keys.delete(field.name).nil?
          # field is missing from row
          missing ||= []
          missing << field.name
        else
          # check field type
          value = row[field.name]
          if !value.nil?
            type = Util.type_of(value)
            if field.type != type
              invalid ||= []
              invalid << "'#{field.name}' (expected #{field.type}, got #{type})"
            end
          end
        end
      end

      errors = nil
      unless missing.nil?
        errors = ["missing fields: #{missing.join(", ")}"]
      end
      unless keys.empty?
        errors ||= []
        errors << "extra fields: #{keys.join(", ")}"
      end
      unless invalid.nil?
        errors ||= []
        errors << "invalid values: #{invalid.join(", ")}"
      end
      unless errors.nil?
        raise InvalidRow, errors.join("; ")
      end
    end
  end
end
