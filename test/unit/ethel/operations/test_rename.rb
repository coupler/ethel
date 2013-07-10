require 'helper'

module TestOperations
  class TestRename < Test::Unit::TestCase
    include ConstantsHelper

    def setup
      @field = stub('original field', :name => 'foo', :type => :string)
      @dataset = stub('dataset', :field => @field)
      @new_field = stub('new field', :name => 'bar')
      Field.stubs(:new).returns(@new_field)
    end

    test "subclass of Operation" do
      assert_equal Operation, Operations::Rename.superclass
    end

    test "alters field during setup callback" do
      op = Operations::Rename.new('foo', 'bar')

      @dataset.expects(:field).with('foo', true).returns(@field)
      Field.expects(:new).with('bar', :type => :string).returns(@new_field)
      @dataset.expects(:alter_field).with('foo', @new_field)
      op.setup(@dataset)
    end

    test "renames field during transform" do
      row = {'foo' => 123}
      op = Operations::Rename.new('foo', 'bar')
      assert_equal({'bar' => 123}, op.transform(row))
    end

    test "registers itself" do
      assert_equal Operations::Rename, Operation.operation('rename')
    end
  end
end
