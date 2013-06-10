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

    test "#before_transform calls Target#add_field" do
      field = stub('field')
      op = Operations::AddField.new(field)

      source = stub('source')
      target = stub('target')
      target.expects(:add_field).with(field)
      op.before_transform(source, target)
    end
  end
end
