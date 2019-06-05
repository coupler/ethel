module Ethel
  module Util
    def self.type_of(value)
      case value
      when Integer
        :integer
      when String
        # TODO: check for blob (look for non-ascii?)
        :string
      when true, false
        :boolean
      when Float
        :float
      when DateTime
        :datetime
      when Date
        :date
      when Time
        :time
      when BigDecimal
        :decimal
      end
    end

    def self.cast(value, new_type, options = {})
      case new_type
      when :integer
        value.to_i
      when :float
        value.to_f
      when :string
        value.to_s
      when :date
        raise "missing date format" if options[:format].nil?
        Date.strptime(value, options[:format])
      end
    end
  end
end
