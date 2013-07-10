require 'helper'

module TestWriters
  class TestMemory < Test::Unit::TestCase
    include ConstantsHelper

    test "subclass of Writer" do
      assert_equal Writer, Writers::Memory.superclass
    end

    test "output to array" do
      writer = Writers::Memory.new

      field_1 = stub('foo field', :name => 'foo', :type => :string)
      field_2 = stub('bar field', :name => 'bar', :type => :string)
      dataset = stub('dataset')
      dataset.expects(:each_field).multiple_yields([field_1], [field_2])
      writer.prepare(dataset)
      writer.add_row({'foo' => '123', 'bar' => '456'})
      assert_equal [{'foo' => '123', 'bar' => '456'}], writer.data
    end

    test "registers itself" do
      assert_equal Writers::Memory, Writer['memory']
    end
  end
end
