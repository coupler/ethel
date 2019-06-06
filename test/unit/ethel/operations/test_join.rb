require 'helper'

module TestOperations
  class TestJoin < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    test "subclass of Operation" do
      assert_equal Operation, Operations::Join.superclass
    end

    test "adds fields during setup callback" do
      target_reader = stub('target reader')
      join_reader = stub('join reader', :each_row => nil)
      opts = {
        origin_fields: [{ name: 'oid', alias: 'origin_id' }],
        target_fields: [{ name: 'tid', alias: 'target_id' }]
      }
      op = Operations::Join.new(target_reader, join_reader, opts)

      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("oid", :type => :integer))

      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("tid", :type => :integer))
      target_dataset.add_field(Field.new("foo", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)

      op.setup(origin_dataset)

      fields = []
      origin_dataset.each_field { |f| fields << f }

      assert_equal 3, fields.length
      assert_equal "origin_id", fields[0].name
      assert_equal :integer, fields[0].type
      assert_equal "target_id", fields[1].name
      assert_equal :integer, fields[1].type
      assert_equal "foo", fields[2].name
      assert_equal :string, fields[2].type
    end

    test "raise error if matching field arrays are different lengths" do
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      opts = {
        origin_fields: ['id1'],
        target_fields: ['foo', 'bar']
      }
      exp = assert_raises do
        Operations::Join.new(target_reader, join_reader, opts)
      end
      assert_kind_of ArgumentError, exp
      assert_equal "origin and target fields must be the same length", exp.message
    end

    test "joins rows during transform" do
      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'fooid', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("fooid", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
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

    test "joins rows with conflicting primary keys during transform" do
      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'origin_id', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("origin_id", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
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

    test "transform skips origin rows with no join table rows" do
      # initialize
      target_reader = stub('target reader', :read => nil)
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'fooid', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("fooid", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
      origin_row = {'id' => 3, 'foo' => 'one'}
      assert_equal(:skip, op.transform(origin_row))
    end

    test "transform skips origin rows with no matching target rows" do
      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'fooid', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("fooid", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
      target_row_1 = {'origin_id' => 3, 'bar' => 'three'}
      target_row_2 = {'origin_id' => 4, 'bar' => 'four'}
      target_reader.expects(:each_row).multiple_yields([target_row_1], [target_row_2])

      origin_row = {'id' => 1, 'foo' => 'one'}
      assert_equal(:skip, op.transform(origin_row))
    end

    test "joins rows during transform with mismatched join table field type" do
      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => '1', 'target_id' => '2'}
      join_row_2 = {'origin_id' => '2', 'target_id' => '1'}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once

      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'fooid', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("fooid", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
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

    test "automatically joins rows with conflicting names during transform" do
      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'origin_id' => 1, 'target_id' => 2}
      join_row_2 = {'origin_id' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'origin_id' }
        ],
        :target_fields => [
          { :name => 'id', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("id", :type => :integer))
      target_dataset.add_field(Field.new("foo", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
      target_row_1 = {'id' => 1, 'foo' => 'target one'}
      target_row_2 = {'id' => 2, 'foo' => 'target two'}
      target_reader.expects(:each_row).multiple_yields([target_row_1], [target_row_2]).twice

      origin_row_1 = {'id' => 1, 'foo' => 'origin one'}
      expected_row_1 = {
        'origin_id' => 1, 'origin_foo' => 'origin one',
        'target_id' => 2, 'target_foo' => 'target two'
      }
      assert_equal(expected_row_1, op.transform(origin_row_1))

      origin_row_2 = {'id' => 2, 'foo' => 'origin two'}
      expected_row_2 = {
        'origin_id' => 2, 'origin_foo' => 'origin two',
        'target_id' => 1, 'target_foo' => 'target one'
      }
      assert_equal(expected_row_2, op.transform(origin_row_2))
    end

    test "handles join alias conflict with origin field" do
      omit("not sure how to fix this yet")

      # initialize
      target_reader = stub('target reader')
      join_reader = stub('join reader')
      join_row_1 = {'foo' => 1, 'target_id' => 2}
      join_row_2 = {'foo' => 2, 'target_id' => 1}
      join_reader.expects(:each_row).multiple_yields([join_row_1], [join_row_2]).once
      op = Operations::Join.new(target_reader, join_reader, {
        :origin_fields => [
          { :name => 'id', :alias => 'foo' }
        ],
        :target_fields => [
          { :name => 'id', :alias => 'target_id' }
        ]
      })

      # setup
      origin_dataset = Dataset.new
      origin_dataset.add_field(Field.new("id", :type => :integer))
      origin_dataset.add_field(Field.new("foo", :type => :string))
      target_dataset = Dataset.new
      target_dataset.add_field(Field.new("id", :type => :integer))
      target_dataset.add_field(Field.new("bar", :type => :string))
      Dataset.expects(:new).returns(target_dataset)
      target_reader.expects(:read).with(target_dataset)
      op.setup(origin_dataset)

      # transform
      target_row_1 = {'id' => 1, 'bar' => 'one'}
      target_row_2 = {'id' => 2, 'bar' => 'two'}
      target_reader.expects(:each_row).multiple_yields([target_row_1], [target_row_2]).twice

      origin_row_1 = {'id' => 1, 'foo' => 'one'}
      expected_row_1 = {
        'foo' => 1, 'origin_foo' => 'one',
        'target_id' => 2, 'bar' => 'target two'
      }
      assert_equal(expected_row_1, op.transform(origin_row_1))

      origin_row_2 = {'id' => 2, 'foo' => 'two'}
      expected_row_2 = {
        'foo' => 2, 'origin_foo' => 'two',
        'target_id' => 1, 'bar' => 'target one'
      }
      assert_equal(expected_row_2, op.transform(origin_row_2))
    end

    test "registers itself" do
      assert_equal Operations::Join, Operation['join']
    end
  end
end
