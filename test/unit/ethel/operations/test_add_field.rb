require 'helper'

module TestOperations
  class TestAddField < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::AddField.superclass
    end

    test "#setup calls Dataset#add_field" do
      op = Operations::AddField.new('foo', :integer)

      field = stub('field')
      Field.expects(:new).with('foo', :type => :integer).returns(field)
      dataset = stub('source')
      dataset.expects(:add_field).with(field)
      op.setup(dataset)
    end

    test "registers itself" do
      assert_equal Operations::AddField, Operation.operation('add_field')
    end
  end
end
