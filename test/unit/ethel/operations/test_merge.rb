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
      op = Operations::Merge.new(reader, :fields => 'id')

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

    test "adds fields during setup callback for multiple fields" do
      reader = stub('reader')
      op = Operations::Merge.new(reader, :fields => ['id1', 'id2'])

      dataset_1 = stub('dataset 1')
      dataset_2 = stub('dataset 2')
      Dataset.expects(:new).returns(dataset_2)
      reader.expects(:read).with(dataset_2)
      field_1 = stub('field 1', :name => 'id1', :type => :integer)
      field_2 = stub('field 2', :name => 'id2', :type => :integer)
      field_3 = stub('field 3', :name => 'foo', :type => :string)
      dataset_2.expects(:each_field).multiple_yields([field_1], [field_2], [field_3])
      dataset_1.expects(:add_field).with(field_3)
      op.setup(dataset_1)
    end

    test "raise error if matching field arrays are different lengths" do
      reader = stub('reader')
      assert_raises do
        Operations::Merge.new(reader, :origin_fields => ['id1', 'id2'], :target_fields => 'foo')
      end
    end

    test "adds data during transform" do
      reader = stub('reader')
      op = Operations::Merge.new(reader, :fields => 'id')

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
      op = Operations::Merge.new(reader, :origin_fields => 'id', :target_fields => 'fooid')

      merge_row_1 = {'fooid' => 1, 'bar' => 123}
      merge_row_2 = {'fooid' => 2, 'bar' => 456}
      reader.expects(:each_row).multiple_yields([merge_row_1], [merge_row_2]).twice

      assert_equal({'id' => 2, 'bar' => 456, 'foo' => 'two'},
        op.transform({'id' => 2, 'foo' => 'two'}))
      assert_equal({'id' => 1, 'bar' => 123, 'foo' => 'one'},
        op.transform({'id' => 1, 'foo' => 'one'}))
    end

    test "using a join table" do
      target_reader = stub('target reader')

      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Merge.new(target_reader, {
        :join_reader => join_reader,
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'fooid', :alias => 'target_id' }
        ]
      })

      target_row_1 = {'fooid' => 1, 'bar' => 'one'}
      target_row_2 = {'fooid' => 2, 'bar' => 'two'}
      target_reader.expects(:each_row).multiple_yields([target_row_1], [target_row_2]).twice

      origin_row_1 = {'id' => 1, 'foo' => 'one'}
      expected_row_1 = {
        'origin_id' => 1, 'foo' => 'one',
        'target_id' => 2, 'bar' => 'two'
      }
      assert_equal(expected_row_1, op.transform(origin_row_1))

      origin_row_2 = {'id' => 2, 'foo' => 'two'}
      expected_row_2 = {
        'origin_id' => 2, 'foo' => 'two',
        'target_id' => 1, 'bar' => 'one'
      }
      assert_equal(expected_row_2, op.transform(origin_row_2))
    end

    test "registers itself" do
      assert_equal Operations::Merge, Operation['merge']
    end
  end
end
