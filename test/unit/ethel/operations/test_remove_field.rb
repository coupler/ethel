require 'helper'

module TestOperations
  class TestRemoveField < Test::Unit::TestCase
    include ConstantsHelper
    scope Ethel

    test "subclass of Operation" do
      assert_equal Operation, Operations::RemoveField.superclass
    end

    test "#setup calls Dataset#remove_field" do
      op = Operations::RemoveField.new('foo')

      dataset = stub('dataset')
      dataset.expects(:remove_field).with('foo')
      op.setup(dataset)
    end

    test "#transform removes field" do
      op = Operations::RemoveField.new('foo')
      row = {'foo' => 123, 'bar' => 456}
      op.transform(row)
      assert_equal({'bar' => 456}, row)
    end

    test "registers itself" do
      assert_equal Operations::RemoveField, Operation['remove_field']
    end
  end
end
