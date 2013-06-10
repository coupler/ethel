require 'helper'

class TestField < Test::Unit::TestCase
  test "name" do
    field = Ethel::Field.new('foo', {:type => :string})
    assert_equal 'foo', field.name
  end

  test "type" do
    field = Ethel::Field.new('foo', {:type => :string})
    assert_equal :string, field.type
  end
end
