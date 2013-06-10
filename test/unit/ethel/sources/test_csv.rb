require 'helper'

module TestSources
  class TestCSV < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    test "subclass of Source" do
      assert_equal Source, Sources::CSV.superclass
    end

    test "load from string" do
      csv = Sources::CSV.new(:string => "foo,bar\n1,2")
      expected_schema = [
        ['foo', { :type => :string }],
        ['bar', { :type => :string }]
      ]
      assert_equal expected_schema, csv.schema
    end

    test "load from file" do
      file = Tempfile.new('csv')
      file.write("foo,bar\n1,2")
      file.close

      csv = Sources::CSV.new(:file => file.path)
      expected_schema = [
        ['foo', { :type => :string }],
        ['bar', { :type => :string }]
      ]
      assert_equal expected_schema, csv.schema
    end

    test "each" do
      csv = Sources::CSV.new(:string => "foo,bar\n1,2\na,b")
      rows = []
      csv.each do |row|
        rows << row
      end
      assert_equal [{'foo' => '1', 'bar' => '2'}, {'foo' => 'a', 'bar' => 'b'}],
        rows
    end
  end
end
