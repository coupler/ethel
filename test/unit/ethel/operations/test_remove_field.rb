require 'helper'

module TestOperations
  class TestRemoveField < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::RemoveField.superclass
    end

    test "#setup calls Dataset#remove_field" do
      op = Operations::RemoveField.new('foo')

      dataset = stub('dataset')
      dataset.expects(:remove_field).with('foo')
      op.setup(dataset)
    end

    test "registers itself" do
      assert_equal Operations::RemoveField, Operation.operation('remove_field')
    end
  end
end
