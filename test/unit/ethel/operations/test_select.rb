require 'helper'

module TestOperations
  class TestSelect < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Select.superclass
    end

    test "#setup calls remove_field for each field not included" do
      field_1 = stub('field 1', :name => 'one')
      field_2 = stub('field 2', :name => 'two')
      field_3 = stub('field 3', :name => 'three')
      field_4 = stub('field 4', :name => 'four')
      field_5 = stub('field 5', :name => 'five')
      op = Operations::Select.new(field_2, field_4, field_5)

      dataset = stub('dataset')
      dataset.expects(:each_field).multiple_yields([field_1], [field_2], [field_3], [field_4], [field_5])
      dataset.expects(:remove_field).with('one')
      dataset.expects(:remove_field).with('three')
      op.setup(dataset)
    end
  end
end
