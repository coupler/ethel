module Ethel
  module Util
    def self.type_of(value)
      case value
      when Fixnum
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
  end
end
