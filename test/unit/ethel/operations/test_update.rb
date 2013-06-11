require 'helper'

module TestOperations
  class TestUpdate < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    def setup
      @field = stub('field', :name => 'foo', :type => :integer)
      @child_operation = stub('child operation')
      Operations::AddField.stubs(:new).returns(@child_operation)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Update.superclass
    end

    test "has AddField child operation with new field" do
      Operations::AddField.expects(:new).with(@field).
        returns(@child_operation)

      op = Operations::Update.new(@field, 123)

      source = stub('source')
      target = stub('target')
      @child_operation.expects(:before_transform).with(source, target)
      op.before_transform(source, target)
    end

    test "update a field's values" do
      row = {'id' => 1, 'foo' => 123, 'bar' => "baz"}
      op = Operations::Update.new(@field, 456)
      @child_operation.stubs(:transform).with(row).returns(row)
      assert_equal({'id' => 1, 'foo' => 456, 'bar' => "baz"}, op.transform(row))
    end

    test "update a field's value with filter" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new(@field, 321) { |v| v > 200 }
      @child_operation.stubs(:transform).with(row_1).returns(row_1)
      assert_equal(row_1, op.transform(row_1.dup))
      @child_operation.stubs(:transform).with(row_2).returns(row_2)
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end

    test "update a field's value with block" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new(@field) { |v| v > 200 ? 321 : v }
      @child_operation.stubs(:transform).with(row_1).returns(row_1)
      assert_equal(row_1, op.transform(row_1.dup))
      @child_operation.stubs(:transform).with(row_2).returns(row_2)
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end

    test "update a field's values with wrong type" do
      assert_raises(InvalidFieldType) do
        Operations::Update.new(@field, "junk")
      end
    end

    test "update a field's values with nil" do
      assert_nothing_raised do
        Operations::Update.new(@field, nil)
      end
    end

    test "update a blob field with string" do
      @field.stubs(:type).returns(:blob)
      assert_nothing_raised do
        Operations::Update.new(@field, "foo")
      end
    end

    test "update a field's value with block with wrong type" do
      row = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      op = Operations::Update.new(@field) { |v| "foo" }
      @child_operation.stubs(:transform).with(row).returns(row)
      assert_raises(InvalidFieldType) do
        op.transform(row)
      end
    end

    test "update a field's value with block with nil" do
      row = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      op = Operations::Update.new(@field) { |v| nil }
      @child_operation.stubs(:transform).with(row).returns(row)
      assert_equal({'id' => 1, 'foo' => nil, 'bar' => 'baz'}, op.transform(row))
    end
  end
end
