module Ethel
  class Field
    VALID_TYPES = [
      :boolean, :integer, :blob, :float, :decimal, :datetime,
      :interval, :set, :string, :date, :time, :enum
    ]

    attr_reader :name, :type

    def initialize(name, options)
      if !name.kind_of?(String)
        raise ArgumentError, "expected name to be a String, but was #{name.class}"
      elsif name == ""
        raise ArgumentError, "name must not be empty"
      end

      @name = name
      raise InvalidFieldType if !VALID_TYPES.include?(options[:type])
      @type = options[:type]
    end
  end
end
