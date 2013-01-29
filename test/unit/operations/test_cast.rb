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
      @new_field = stub('new field')
      Field.stubs(:new).returns(@new_field)
      @child_operation = stub('child operation')
      Operations::AddField.stubs(:new).returns(@child_operation)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Cast.superclass
    end

    test "has AddField child operation with new field" do
      Field.expects(:new).with('foo', :type => :integer).returns(@new_field)
      Operations::AddField.expects(:new).with(@new_field).
        returns(@child_operation)

      op = Operations::Cast.new(@original_field, :integer)

      source = stub('source')
      target = stub('target')
      @child_operation.expects(:before_transform).with(source, target)
      op.before_transform(source, target)
    end

    test "uses to_i when casting to integer" do
      row = {'foo' => '123'}
      op = Operations::Cast.new(@original_field, :integer)
      @child_operation.stubs(:transform).with(row).returns(row)
      assert_equal({'foo' => 123}, op.transform(row))
    end

    test "uses to_s when casting to string" do
      row = {'foo' => 123}
      op = Operations::Cast.new(@original_field, :string)
      @child_operation.stubs(:transform).with(row).returns(row)
      assert_equal({'foo' => '123'}, op.transform(row))
    end
  end
end
