require 'helper'

class TestUtil < Test::Unit::TestCase
  type_of_tests = {
    123 => :integer,
    "foo" => :string,
    true => :boolean,
    false => :boolean,
    1.5 => :float,
    Date.today => :date,
    DateTime.now => :datetime,
    Time.now => :time,
    BigDecimal.new(0) => :decimal
  }
  type_of_tests.each_pair do |value, expected|
    test "type_of(#{value.inspect}) is #{expected}" do
      assert_equal expected, Ethel::Util.type_of(value)
    end
  end
end
