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

        dataset = Dataset.new
        dataset.add_field(Field.new('foo', :type => :string))
        dataset.add_field(Field.new('bar', :type => :string))
        csv.prepare(dataset)
        csv.add_row({'foo' => '123', 'bar' => '456'})
        csv.flush

        file.rewind
        assert_equal "foo,bar\n123,456\n", file.read
      end

      test "output to string" do
        csv = Writer.new(:string => true)

        dataset = Dataset.new
        dataset.add_field(Field.new('foo', :type => :string))
        dataset.add_field(Field.new('bar', :type => :string))
        csv.prepare(dataset)
        csv.add_row({'foo' => '123', 'bar' => '456'})
        csv.flush

        assert_equal "foo,bar\n123,456\n", csv.data
      end

      test "default date to string conversion" do
        csv = Writer.new(:string => true)

        dataset = Dataset.new
        dataset.add_field(Field.new('foo', :type => :date))
        csv.prepare(dataset)
        csv.add_row({'foo' => Date.new(2019, 1, 2)})
        csv.flush

        assert_equal "foo\n2019-01-02\n", csv.data
      end

      test "custom date to string conversion" do
        csv = Writer.new(:string => true, :date_format => "%m/%d/%Y")

        dataset = Dataset.new
        dataset.add_field(Field.new('foo', :type => :date))
        csv.prepare(dataset)
        csv.add_row({'foo' => Date.new(2019, 1, 2)})
        csv.flush

        assert_equal "foo\n01/02/2019\n", csv.data
      end

      test "registers itself" do
        assert_equal Writer, ::Ethel::Writer['csv']
      end
    end
  end
end
