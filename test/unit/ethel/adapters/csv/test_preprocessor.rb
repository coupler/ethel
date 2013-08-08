require 'helper'

module TestAdapters
  module TestCSV
    class TestPreprocessor < Test::Unit::TestCase
      include ConstantsHelper
      scope Ethel::Adapters::CSV

      test "subclass of Preprocessor" do
        assert_equal ::Ethel::Preprocessor, Preprocessor.superclass
      end

      test "#check for properly formatted CSV" do
        prep = Preprocessor.new(:string => "foo,bar\n1,2")
        assert prep.check
      end

      test "#check when headers row has empty column" do
        prep = Preprocessor.new(:string => "foo,\n1,2")
        assert !prep.check

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
    end
  end
end
