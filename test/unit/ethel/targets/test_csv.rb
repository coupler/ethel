require 'helper'

module TestTargets
  class TestCSV < Test::Unit::TestCase
    def self.const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end

    test "subclass of Target" do
      assert_equal Target, Targets::CSV.superclass
    end

    test "output to file" do
      file = Tempfile.new('csv')
      field = stub('field', :name => 'foo', :type => :string)
      csv = Targets::CSV.new(:file => file.path)
      csv.add_field(field)
      csv.add_row({'foo' => 'bar'})
      csv.flush

      file.rewind
      assert_equal "foo\nbar\n", file.read
    end

    test "output to string" do
      field = stub('field', :name => 'foo', :type => :string)
      csv = Targets::CSV.new(:string => true)
      csv.add_field(field)
      csv.add_row({'foo' => 'bar'})
      csv.flush

      assert_equal "foo\nbar\n", csv.data
    end
  end
end
