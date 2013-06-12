require 'helper'

module TestOperations
  class TestCast < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    def setup
      @original_field = stub('original field', :name => 'foo')
      @new_field = stub('new field', :name => 'foo')
      Field.stubs(:new).returns(@new_field)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Cast.superclass
    end

    test "alters field during setup callback" do
      @original_field.stubs(:type).returns(:string)

      Field.expects(:new).with('foo', :type => :integer).returns(@new_field)
      @new_field.stubs(:type).returns(:integer)
      op = Operations::Cast.new(@original_field, :integer)

      dataset = stub('dataset')
      dataset.expects(:alter_field).with('foo', @new_field)
      op.setup(dataset)
    end

    test "uses to_i when casting to integer" do
      @original_field.stubs(:type).returns(:string)
      @new_field.stubs(:type).returns(:integer)
      op = Operations::Cast.new(@original_field, :integer)
      row = {'foo' => '123'}
      assert_equal({'foo' => 123}, op.transform(row))
    end

    test "uses to_s when casting to string" do
      @original_field.stubs(:type).returns(:integer)
      @new_field.stubs(:type).returns(:string)
      op = Operations::Cast.new(@original_field, :string)
      row = {'foo' => 123}
      assert_equal({'foo' => '123'}, op.transform(row))
    end
  end
end
