require 'helper'

class TestError < Test::Unit::TestCase
  def new_subclass(&block)
    Class.new(Ethel::Error, &block)
  end

  test "#message" do
    err = Ethel::Error.new("foo", false)
    assert_equal "foo", err.message
  end

  test "#recoverable?" do
    err = Ethel::Error.new("foo", false)
    assert !err.recoverable?
  end

  test "#info" do
    err = Ethel::Error.new("foo", false, {:line => 123})
    assert_equal({:line => 123}, err.info)
  end

  test "#each_choice" do
    klass = new_subclass do
      def choices
        [{:foo => {:baz => :string}}, :bar]
      end
    end
    err = klass.new("foo", true, {:line => 123})

    i = 0
    err.each_choice do |name, args|
      case i
      when 0
        assert_equal(:foo, name)
        assert_equal({:baz => :string}, args)
      when 1
        assert_equal(:bar, name)
        assert_equal({}, args)
      end
      i += 1
    end
    assert_equal 2, i
  end

  test "#choose" do
    klass = new_subclass do
      def choices
        [:foo, :bar]
      end
    end
    err = klass.new("foo", true)
    err.choose(:foo)
    assert_equal :foo, err.choice
  end

  test "#choose with string parameter" do
    klass = new_subclass do
      def choices
        [:foo => {:baz => :string}]
      end
    end
    err = klass.new("foo", true)
    err.choose(:foo, {:baz => "blah"})
    assert_equal [:foo, {:baz => "blah"}], err.choice
  end

  test "#choose with missing argument" do
    klass = new_subclass do
      def choices
        [:foo => {:baz => :string}]
      end
    end
    err = klass.new("foo", true)
    assert_raises(Ethel::InvalidChoice) do
      err.choose(:foo)
    end
  end

  test "#choose with wrong argument type" do
    klass = new_subclass do
      def choices
        [:foo => {:baz => :string}]
      end
    end
    err = klass.new("foo", true)
    assert_raises(Ethel::InvalidChoice) do
      err.choose(:foo, {:baz => 123})
    end
  end

  test "#choose with non-hash args" do
    klass = new_subclass do
      def choices
        [:foo => {:baz => :string}]
      end
    end
    err = klass.new("foo", true)
    assert_raises(ArgumentError) do
      err.choose(:foo, 123)
    end
  end
end
