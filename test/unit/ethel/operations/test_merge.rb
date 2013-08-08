require 'helper'

module TestOperations
  class TestMerge < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    test "subclass of Operation" do
      assert_equal Operation, Operations::Merge.superclass
    end

    test "adds fields during setup callback" do
      reader = stub('reader')
      op = Operations::Merge.new(reader, 'id')

      dataset_1 = stub('dataset 1')
      dataset_2 = stub('dataset 2')
      Dataset.expects(:new).returns(dataset_2)
      reader.expects(:read).with(dataset_2)
      field_1 = stub('field 1', :name => 'id', :type => :integer)
      field_2 = stub('field 2', :name => 'foo', :type => :string)
      dataset_2.expects(:each_field).multiple_yields([field_1], [field_2])
      dataset_1.expects(:add_field).with(field_2)
      op.setup(dataset_1)
    end

    test "adds data during transform" do
      reader = stub('reader')
      op = Operations::Merge.new(reader, 'id')

      merge_row_1 = {'id' => 1, 'bar' => 123}
      merge_row_2 = {'id' => 2, 'bar' => 456}
      reader.expects(:each_row).multiple_yields([merge_row_1], [merge_row_2]).twice

      assert_equal({'id' => 2, 'bar' => 456, 'foo' => 'two'},
        op.transform({'id' => 2, 'foo' => 'two'}))
      assert_equal({'id' => 1, 'bar' => 123, 'foo' => 'one'},
        op.transform({'id' => 1, 'foo' => 'one'}))
    end

    test "matching on different field names" do
      reader = stub('reader')
      op = Operations::Merge.new(reader, 'id', 'fooid')

      merge_row_1 = {'fooid' => 1, 'bar' => 123}
      merge_row_2 = {'fooid' => 2, 'bar' => 456}
      reader.expects(:each_row).multiple_yields([merge_row_1], [merge_row_2]).twice

      assert_equal({'id' => 2, 'bar' => 456, 'foo' => 'two'},
        op.transform({'id' => 2, 'foo' => 'two'}))
      assert_equal({'id' => 1, 'bar' => 123, 'foo' => 'one'},
        op.transform({'id' => 1, 'foo' => 'one'}))
    end

    test "registers itself" do
      assert_equal Operations::Merge, Operation['merge']
    end
  end
end
