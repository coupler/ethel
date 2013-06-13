require 'helper'

module TestOperations
  class TestUpdate < Test::Unit::TestCase
    include ConstantsHelper

    def setup
      @field = stub('field', :name => 'foo', :type => :integer)
      @dataset = stub('dataset')
      @dataset.stubs(:field).with('foo').returns(@field)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Update.superclass
    end

    test "update a field's values" do
      row = {'id' => 1, 'foo' => 123, 'bar' => "baz"}
      op = Operations::Update.new('foo', 456)
      op.setup(@dataset)
      assert_equal({'id' => 1, 'foo' => 456, 'bar' => "baz"}, op.transform(row))
    end

    test "update a field's value with filter" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new('foo', 321) { |v| v > 200 }
      op.setup(@dataset)
      assert_equal(row_1, op.transform(row_1.dup))
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end

    test "update a field's value with block" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new('foo') { |v| v > 200 ? 321 : v }
      op.setup(@dataset)
      assert_equal(row_1, op.transform(row_1.dup))
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end

    test "update a field's values with wrong type" do
      op = Operations::Update.new('foo', "junk")
      assert_raises(InvalidFieldType) do
        op.setup(@dataset)
      end
    end

    test "update a field's values with nil" do
      op = Operations::Update.new('foo', nil)
      assert_nothing_raised do
        op.setup(@dataset)
      end
    end

    test "update a blob field with string" do
      op = Operations::Update.new('foo', "foo")
      @field.stubs(:type).returns(:blob)
      assert_nothing_raised do
        op.setup(@dataset)
      end
    end

    test "update a field's value with block with wrong type" do
      row = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      op = Operations::Update.new('foo') { |v| "foo" }
      op.setup(@dataset)
      assert_raises(InvalidFieldType) do
        op.transform(row)
      end
    end

    test "update a field's value with block with nil" do
      row = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      op = Operations::Update.new('foo') { |v| nil }
      assert_equal({'id' => 1, 'foo' => nil, 'bar' => 'baz'}, op.transform(row))
    end

    test "registers itself" do
      assert_equal Operations::Update, Operation.operation('update')
    end
  end
end
