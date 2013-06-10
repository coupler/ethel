module Ethel
  class Field
    VALID_TYPES = [
      :boolean, :integer, :blob, :integer, :float, :decimal, :datetime,
      :interval, :set, :string, :date, :time, :enum
    ]

    attr_reader :name, :type

    def initialize(name, options)
      @name = name
      raise InvalidFieldType if !VALID_TYPES.include?(options[:type])
      @type = options[:type]
    end
  end
end
