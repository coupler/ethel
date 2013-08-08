require 'helper'

class TestPreprocessor < Test::Unit::TestCase
  include ConstantsHelper
  scope Ethel

  def setup
    @original_preprocessors = Preprocessor.instance_variable_get(:@subclasses)
  end

  def teardown
    Preprocessor.instance_variable_set(:@subclasses, @original_preprocessors)
  end

  def new_subclass(&block)
    Class.new(Preprocessor, &block)
  end

  test "registering a preprocessor" do
    klass = new_subclass
    Preprocessor.register('foo', klass)
    assert_equal klass, Preprocessor['foo']
  end

  test "#options" do
    options = {'foo' => 123}
    prep = Preprocessor.new(options)
    assert_same options, prep.options
  end

  test "#check" do
    prep = Preprocessor.new('foo' => 123)
    assert prep.check
  end

  test "#each_error" do
    error = stub('error')
    klass = new_subclass do
      def initialize(options)
        super
      end
    end
    klass.send(:define_method, :check) do
      @errors << error
      false
    end
    prep = klass.new('foo' => 123)
    prep.check

    ok = false
    prep.each_error do |e|
      ok = error == e
    end
    assert ok
  end
end
