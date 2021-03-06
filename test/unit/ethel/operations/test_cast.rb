require 'helper'

module TestOperations
  class TestCast < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    def setup
      @new_field = stub('new field', :name => 'foo')
      Field.stubs(:new).returns(@new_field)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Cast.superclass
    end

    test "alters field during setup callback" do
      op = Operations::Cast.new('foo', :integer)

      Field.expects(:new).with('foo', :type => :integer).returns(@new_field)
      @new_field.stubs(:type).returns(:integer)
      dataset = stub('dataset')
      dataset.expects(:alter_field).with('foo', @new_field)
      op.setup(dataset)
    end

    test "uses to_i when casting to integer" do
      op = Operations::Cast.new('foo', :integer)
      row = {'foo' => '123'}
      assert_equal({'foo' => 123}, op.transform(row))
    end

    test "uses to_s when casting to string" do
      op = Operations::Cast.new('foo', :string)
      row = {'foo' => 123}
      assert_equal({'foo' => '123'}, op.transform(row))
    end

    test "uses to_f when casting to integer" do
      op = Operations::Cast.new('foo', :float)
      row = {'foo' => '1.0'}
      assert_equal({'foo' => 1.0}, op.transform(row))
    end

    test "uses strptime when casting to date" do
      op = Operations::Cast.new('foo', :date, :format => '%Y-%m-%d')
      row = {'foo' => '2019-01-01'}
      expected = {'foo' => Date.new(2019, 1, 1)}
      assert_equal(expected, op.transform(row))
    end

    test "raises error if date format is not given when casting to date" do
      assert_raises do
        Operations::Cast.new('foo', :date)
      end
    end

    test "registers itself" do
      assert_equal Operations::Cast, Operation['cast']
    end
  end
end
