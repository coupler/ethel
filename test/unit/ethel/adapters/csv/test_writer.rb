require 'helper'

module TestAdapters
  module TestCSV
    class TestWriter < Test::Unit::TestCase
      include ConstantsHelper
      scope Ethel::Adapters::CSV

      test "subclass of Writer" do
        assert_equal ::Ethel::Writer, Writer.superclass
      end

      test "initialize with invalid options" do
        assert_raises do
          Writer.new({})
        end
      end

      test "output to file" do
        file = Tempfile.new('csv')
        csv = Writer.new(:file => file.path)

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
        csv = Writer.new(:string => true)

        field_1 = stub('foo field', :name => 'foo', :type => :string)
        field_2 = stub('bar field', :name => 'bar', :type => :string)
        dataset = stub('dataset')
        dataset.expects(:each_field).multiple_yields([field_1], [field_2])
        csv.prepare(dataset)
        csv.add_row({'foo' => '123', 'bar' => '456'})
        csv.flush

        assert_equal "foo,bar\n123,456\n", csv.data
      end

      test "registers itself" do
        assert_equal Writer, ::Ethel::Writer['csv']
      end
    end
  end
end
