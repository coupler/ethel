require 'helper'

class TestField < Test::Unit::TestCase
  test "name" do
    field = Ethel::Field.new('foo', {:type => :string})
    assert_equal 'foo', field.name
  end

  test "requires string name" do
    assert_raises(ArgumentError) do
      Ethel::Field.new(123, {:type => :string})
    end
  end

  test "requires non-empty string name" do
    assert_raises(ArgumentError) do
      Ethel::Field.new("", {:type => :string})
    end
  end

  test "type" do
    field = Ethel::Field.new('foo', {:type => :string})
    assert_equal :string, field.type
  end

  test "invalid type" do
    assert_raises(Ethel::InvalidFieldType) do
      Ethel::Field.new('foo', {:type => :bogus})
    end
  end
end
