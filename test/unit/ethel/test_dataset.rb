require 'helper'

class TestDataset < Test::Unit::TestCase
  test "#add_field" do
    dataset = Ethel::Dataset.new
    field = stub('field', :name => 'foo')
    dataset.add_field(field)
  end

  test "#add_field with duplicate name" do
    dataset = Ethel::Dataset.new
    field = stub('field', :name => 'foo')
    dataset.add_field(field)
    assert_raises(Ethel::InvalidFieldName) do
      dataset.add_field(field)
    end
  end

  test "#remove_field" do
    dataset = Ethel::Dataset.new
    field = stub('field', :name => 'foo')
    dataset.add_field(field)
    dataset.remove_field('foo')
  end

  test "#remove_field with nonexistant name" do
    dataset = Ethel::Dataset.new
    assert_raises(Ethel::NonexistentField) do
      dataset.remove_field('foo')
    end
  end

  test "#alter_field with different name" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo')
    dataset.add_field(field_1)

    field_2 = stub('field', :name => 'bar')
    dataset.alter_field('foo', field_2)

    field_3 = stub('field', :name => 'baz')
    dataset.alter_field('bar', field_3)
  end

  test "#alter_field with nonexistent name" do
    dataset = Ethel::Dataset.new

    field = stub('field', :name => 'bar')
    assert_raises(Ethel::NonexistentField) do
      dataset.alter_field('foo', field)
    end
  end

  test "#alter_field with different type" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)

    field_2 = stub('field', :name => 'foo', :type => :string)
    dataset.alter_field('foo', field_2)

    field_3 = stub('field', :name => 'foo', :type => :date)
    dataset.alter_field('foo', field_3)
  end

  test "#each_field" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    actual_fields = []
    dataset.each_field do |field|
      actual_fields << field
    end
    assert_equal([field_1, field_2], actual_fields)
  end

  test "#field" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    assert_equal field_1, dataset.field('foo')
    assert_equal field_2, dataset.field('bar')
  end

  test "#field with assertion" do
    dataset = Ethel::Dataset.new
    field = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field)

    assert_raises(Ethel::NonexistentField) do
      dataset.field('baz', true)
    end
  end

  test "#validate_row raises exception for missing column" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    assert_raises(Ethel::InvalidRow) do
      dataset.validate_row({'foo' => 123})
    end
  end

  test "#validate_row raises exception for extra column" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    assert_raises(Ethel::InvalidRow) do
      dataset.validate_row({'foo' => 123, 'bar' => 'blah', 'baz' => 456})
    end
  end

  test "#validate_row raises exception for column with wrong type" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    assert_raises(Ethel::InvalidRow) do
      dataset.validate_row({'foo' => 'string', 'bar' => 'blah'})
    end
  end

  test "#validate_row treats nil as match" do
    dataset = Ethel::Dataset.new
    field_1 = stub('field', :name => 'foo', :type => :integer)
    dataset.add_field(field_1)
    field_2 = stub('field', :name => 'bar', :type => :string)
    dataset.add_field(field_2)

    assert_nothing_raised do
      dataset.validate_row({'foo' => nil, 'bar' => nil})
    end
  end
end
