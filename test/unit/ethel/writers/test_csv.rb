require 'helper'

module TestWriters
  class TestCSV < Test::Unit::TestCase
    include ConstantsHelper

    test "subclass of Writer" do
      assert_equal Writer, Writers::CSV.superclass
    end

    test "output to file" do
      file = Tempfile.new('csv')
      csv = Writers::CSV.new(:file => file.path)

      field_1 = stub('foo field', :name => 'foo', :type => :string)
      field_2 = stub('bar field', :name => 'bar', :type => :string)
      dataset = stub('dataset')
      dataset.expects(:each_field).multiple_yields([field_1], [field_2])
      csv.prepare(dataset)
      csv.add_row({'foo' => '123', 'bar' => '456'})
      csv.flush

      file.rewind
      assert_equal "foo,bar\n123,456\n", file.read
    end

    test "output to string" do
      csv = Writers::CSV.new(:string => true)

      field_1 = stub('foo field', :name => 'foo', :type => :string)
      field_2 = stub('bar field', :name => 'bar', :type => :string)
      dataset = stub('dataset')
      dataset.expects(:each_field).multiple_yields([field_1], [field_2])
      csv.prepare(dataset)
      csv.add_row({'foo' => '123', 'bar' => '456'})
      csv.flush

      assert_equal "foo,bar\n123,456\n", csv.data
    end
  end
end
