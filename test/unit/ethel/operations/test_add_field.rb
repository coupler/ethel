require 'helper'

module TestOperations
  class TestAddField < Test::Unit::TestCase
    include ConstantsHelper

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
      assert_equal Operations::AddField, Operation['add_field']
    end
  end
end
