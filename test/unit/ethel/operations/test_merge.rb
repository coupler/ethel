require 'helper'

module TestOperations
  class TestMerge < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    test "subclass of Operation" do
      assert_equal Operation, Operations::Merge.superclass
    end

    test "adds fields during setup callback" do
      target_reader = stub('target reader')
      op = Operations::Merge.new(target_reader, :fields => 'id')

      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))

      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("id", :type => :integer))
      target_dataset.add_field(Field.new("foo", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)

      op.setup(origin_dataset)

      field = origin_dataset.field("foo", true)
      assert_equal "foo", field.name
      assert_equal :string, field.type
    end

    test "adds fields during setup callback for multiple fields" do
      target_reader = stub('target reader')
      op = Operations::Merge.new(target_reader, :fields => ['id1', 'id2'])

      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id1", :type => :integer))
      origin_dataset.add_field(Field.new("id2", :type => :integer))

      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("id1", :type => :integer))
      target_dataset.add_field(Field.new("id2", :type => :integer))
      target_dataset.add_field(Field.new("foo", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)

      op.setup(origin_dataset)

      field = origin_dataset.field("foo", true)
      assert_equal "foo", field.name
      assert_equal :string, field.type
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

    test "using a join table with conflicting field names" do
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
          { :name => 'origin_id', :alias => 'target_id' }
        ]
      })

      target_row_1 = {'origin_id' => 1, 'bar' => 'one'}
      target_row_2 = {'origin_id' => 2, 'bar' => 'two'}
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
