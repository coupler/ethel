require 'helper'

module TestAdapters
  module TestCSV
    class TestReader < Test::Unit::TestCase
      include ConstantsHelper
      scope Ethel::Adapters::CSV

      test "subclass of Reader" do
        assert_equal ::Ethel::Reader, Reader.superclass
      end

      test "initialize with invalid options" do
        assert_raises do
          Reader.new({})
        end
      end

      test "#read from string" do
        csv = Reader.new(:string => "foo,bar\n1,2")
        dataset = stub('dataset')

        field_1 = stub('foo field', :name => 'foo')
        Field.expects(:new).with('foo', :type => :string).returns(field_1)
        dataset.expects(:add_field).with(field_1)

        field_2 = stub('bar field', :name => 'bar')
        Field.expects(:new).with('bar', :type => :string).returns(field_2)
        dataset.expects(:add_field).with(field_2)

        csv.read(dataset)
      end

      test "#read from file" do
        file = Tempfile.new('csv')
        file.write("foo,bar\n1,2")
        file.close

        csv = Reader.new(:file => file.path)
        dataset = stub('dataset')

        field_1 = stub('foo field', :name => 'foo')
        Field.expects(:new).with('foo', :type => :string).returns(field_1)
        dataset.expects(:add_field).with(field_1)

        field_2 = stub('bar field', :name => 'bar')
        Field.expects(:new).with('bar', :type => :string).returns(field_2)
        dataset.expects(:add_field).with(field_2)

        csv.read(dataset)
      end

      test "#each_row from string" do
        csv = Reader.new(:string => "foo,bar\n1,2\na,b")
        rows = []
        csv.each_row do |row|
          rows << row
        end
        expected = [{'foo' => '1', 'bar' => '2'}, {'foo' => 'a', 'bar' => 'b'}]
        assert_equal(expected, rows)
      end

      test "#each_row from file" do
        file = Tempfile.new('csv')
        file.write("foo,bar\n1,2\na,b")
        file.close

        csv = Reader.new(:file => file.path)
        rows = []
        csv.each_row do |row|
          rows << row
        end
        expected = [{'foo' => '1', 'bar' => '2'}, {'foo' => 'a', 'bar' => 'b'}]
        assert_equal(expected, rows)
      end

      test "registers itself" do
        assert_equal Reader, ::Ethel::Reader['csv']
      end
    end
  end
end
