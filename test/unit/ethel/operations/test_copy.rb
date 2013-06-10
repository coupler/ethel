require 'helper'

module TestOperations
  class TestCopy < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    def setup
      @field = stub('field', :name => 'foo')
      @child_operation = stub('child operation')
      Operations::AddField.stubs(:new).returns(@child_operation)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Copy.superclass
    end

    test "has AddField child operation with same field" do
      Operations::AddField.expects(:new).with(@field).
        returns(@child_operation)

      op = Operations::Copy.new(@field)

      source = stub('source')
      target = stub('target')
      @child_operation.expects(:before_transform).with(source, target)
      op.before_transform(source, target)
    end
  end
end
