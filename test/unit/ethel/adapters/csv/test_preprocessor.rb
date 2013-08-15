require 'helper'

module TestAdapters
  module TestCSV
    class TestPreprocessor < Test::Unit::TestCase
      include ConstantsHelper
      scope Ethel::Adapters::CSV

      test "subclass of Preprocessor" do
        assert_equal ::Ethel::Preprocessor, Preprocessor.superclass
      end

      test "check for properly formatted CSV" do
        prep = Preprocessor.new(:string => "foo,bar\n1,2")
        assert prep.valid?
      end

      test "check when headers row has empty column" do
        prep = Preprocessor.new(:string => "foo,\n1,2")
        assert !prep.valid?

        ok = false
        prep.each_error do |error|
          assert_equal "missing field name", error.message
          assert error.recoverable?
          assert_equal({:colnum => 1}, error.info)

          i = 0
          error.each_choice do |name, args|
            case i
            when 0
              assert_equal :rename, name
              assert_equal({:name => :string}, args)
            when 1
              assert_equal :drop, name
              assert_equal({}, args)
            end
            i += 1
          end
          ok = i == 2
        end
        assert ok
      end

      test "process to string with renamed column" do
        prep = Preprocessor.new(:string => "foo,\n1,2")
        assert !prep.valid?
        prep.each_error do |error|
          error.choose(:rename, :name => 'bar')
        end

        output = prep.run(:string => true)
        assert_equal "foo,bar\n1,2\n", output
      end

      test "process to file with renamed column" do
        in_file = Tempfile.new('ethel-in')
        in_file.puts("foo,")
        in_file.puts("1,2")
        in_file.close

        prep = Preprocessor.new(:file => in_file.path)
        assert !prep.valid?
        prep.each_error do |error|
          error.choose(:rename, :name => 'bar')
        end

        out_file = Tempfile.new('ethel-out')
        out_file.close
        prep.run(:file => out_file.path)
        assert_equal "foo,bar\n1,2\n", File.read(out_file.path)
      end

      test "process to string with dropped column" do
        prep = Preprocessor.new(:string => "foo,\n1,2")
        assert !prep.valid?
        prep.each_error do |error|
          error.choose(:drop)
        end

        output = prep.run(:string => true)
        assert_equal "foo\n1\n", output
      end
    end
  end
end
