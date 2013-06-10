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
      @field = stub('field', :name => 'foo')
    end

    test "update a field's values" do
      row = {'id' => 1, 'foo' => 123, 'bar' => "baz"}
      op = Operations::Update.new(@field, 456)
      assert_equal({'id' => 1, 'foo' => 456, 'bar' => "baz"}, op.transform(row))
    end

    test "update a field's value with filter" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new(@field, 321) { |v| v > 200 }
      assert_equal(row_1, op.transform(row_1.dup))
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end

    test "update a field's value with block" do
      row_1 = {'id' => 1, 'foo' => 123, 'bar' => 'baz'}
      row_2 = {'id' => 2, 'foo' => 456, 'bar' => 'baz'}
      op = Operations::Update.new(@field) { |v| v > 200 ? 321 : v }
      assert_equal(row_1, op.transform(row_1.dup))
      assert_equal({'id' => 2, 'foo' => 321, 'bar' => 'baz'}, op.transform(row_2))
    end
  end
end
