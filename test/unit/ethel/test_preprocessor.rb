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

  test "#valid? is false when validate adds errors" do
    klass = new_subclass do
      def validate
        @errors << 'foo'
      end
    end
    prep = klass.new('foo' => 123)
    assert !prep.valid?
  end

  test "#each_error" do
    error = stub('error')
    klass = new_subclass do
      def initialize(options)
        super
      end
    end
    klass.send(:define_method, :validate) do
      @errors << error
    end
    prep = klass.new('foo' => 123)
    assert !prep.valid?

    ok = false
    prep.each_error do |e|
      ok = error == e
    end
    assert ok
  end

  test "#run with no errors does nothing" do
    klass = new_subclass
    prep = klass.new('foo' => 123)
    prep.expects(:process).never
    prep.run
  end

  test "#run with unresolved errors raises exception" do
    klass = new_subclass
    error = stub('error', :choice => nil)
    klass.send(:define_method, :validate) do
      @errors << error
    end

    prep = klass.new('foo' => 123)
    assert !prep.valid?
    assert_raises do
      prep.run
    end
  end

  test "#run with resolved errors" do
    klass = new_subclass
    error = stub('error', :choice => :foo)
    klass.send(:define_method, :validate) do
      @errors << error
    end

    prep = klass.new('foo' => 123)
    assert !prep.valid?
    prep.expects(:process).with(:some_option => true).returns('some output')
    assert_equal 'some output', prep.run(:some_option => true)
  end
end
