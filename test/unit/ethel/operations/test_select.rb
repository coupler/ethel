require 'helper'

module TestOperations
  class TestSelect < Test::Unit::TestCase
    include ConstantsHelper

    test "subclass of Operation" do
      assert_equal Operation, Operations::Select.superclass
    end

    test "#setup calls remove_field for each field not included" do
      op = Operations::Select.new('two', 'four', 'five')

      field_1 = stub('field 1', :name => 'one')
      field_2 = stub('field 2', :name => 'two')
      field_3 = stub('field 3', :name => 'three')
      field_4 = stub('field 4', :name => 'four')
      field_5 = stub('field 5', :name => 'five')
      dataset = stub('dataset')
      dataset.expects(:each_field).multiple_yields([field_1], [field_2], [field_3], [field_4], [field_5])
      dataset.expects(:remove_field).with('one')
      dataset.expects(:remove_field).with('three')
      op.setup(dataset)
    end

    test "#transform removes fields" do
      row = {'foo' => 123, 'bar' => 456, 'baz' => 789}
      op = Operations::Select.new('foo', 'bar')
      expected = row.reject { |k, v| k == 'baz' }
      actual = op.transform(row.dup)
      assert_equal(expected, actual)
    end

    test "registers itself" do
      assert_equal Operations::Select, Operation['select']
    end
  end
end
