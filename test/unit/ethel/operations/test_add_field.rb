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
      field = stub('field')
      op = Operations::AddField.new(field)

      dataset = stub('source')
      dataset.expects(:add_field).with(field)
      op.setup(dataset)
    end
  end
end
