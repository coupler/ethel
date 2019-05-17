require 'helper'

module TestOperations
  class TestShiftDate < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    test "subclass of Operation" do
      assert_equal Operation, Operations::ShiftDate.superclass
    end

    test "does nothing during setup if dataset is valid" do
      dataset = Dataset.new
      dataset.add_field(Field.new('id', :type => :integer))
      dataset.add_field(Field.new('foo', :type => :date))

      op = Operations::ShiftDate.new('foo', 'id')
      op.setup(dataset)
    end

    test "raises error during setup if field is not date" do
      dataset = Dataset.new
      dataset.add_field(Field.new('id', :type => :integer))
      dataset.add_field(Field.new('foo', :type => :string))

      op = Operations::ShiftDate.new('foo', 'id')
      assert_raises do
        op.setup(dataset)
      end
    end

    test "raises error during setup if field is missing" do
      dataset = Dataset.new
      dataset.add_field(Field.new('id', :type => :integer))

      op = Operations::ShiftDate.new('foo', 'id')
      assert_raises do
        op.setup(dataset)
      end
    end

    test "raises error during setup if key is missing" do
      dataset = Dataset.new
      dataset.add_field(Field.new('foo', :type => :date))

      op = Operations::ShiftDate.new('foo', 'id')
      assert_raises do
        op.setup(dataset)
      end
    end

    test "raises error during transform if key value is nil" do
      op = Operations::ShiftDate.new('foo', 'id')
      assert_raises do
        op.transform({'foo' => Date.new(2015, 1, 1)})
      end
    end

    test "raises error during transform if field value is not a date" do
      op = Operations::ShiftDate.new('foo', 'id')
      assert_raises do
        op.transform({'id' => 1, 'foo' => 'foo'})
      end
    end

    test "transform shifts date" do
      op = Operations::ShiftDate.new('foo', 'id')
      row = {'id' => 1, 'foo' => Date.new(2015, 1, 1)}
      result = op.transform(row)
      assert_not_equal row['foo'], result['foo']
      assert (result['foo'] - row['foo']) > 0
    end

    test "transform shifts dates consistently across rows with matching keys" do
      op = Operations::ShiftDate.new('foo', 'id')
      result_1 = op.transform({'id' => 1, 'foo' => Date.new(2015, 1, 1)})
      result_2 = op.transform({'id' => 1, 'foo' => Date.new(2015, 1, 2)})
      assert_equal 1, result_2['foo'] - result_1['foo']
    end

    test "transform shifts dates differently across rows with different keys" do
      op = Operations::ShiftDate.new('foo', 'id')
      result_1 = op.transform({'id' => 1, 'foo' => Date.new(2015, 1, 1)})
      result_2 = op.transform({'id' => 2, 'foo' => Date.new(2015, 1, 1)})
      assert_not_equal result_1['foo'], result_2['foo']
    end

    test "registers itself" do
      assert_equal Operations::ShiftDate, Operation['shift_date']
    end
  end
end
