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
      assert_equal %w{foo bar}, csv.field_names
    end

    test "load from file" do
      file = Tempfile.new('csv')
      file.write("foo,bar\n1,2")
      file.close

      csv = Sources::CSV.new(:file => file.path)
      assert_equal %w{foo bar}, csv.field_names
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
