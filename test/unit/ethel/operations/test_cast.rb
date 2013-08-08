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

    test "registers itself" do
      assert_equal Operations::Cast, Operation['cast']
    end
  end
end
