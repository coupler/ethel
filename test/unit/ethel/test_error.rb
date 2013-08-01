require 'helper'

class TestError < Test::Unit::TestCase
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

  test "#choose" do
    err = Ethel::Error.new("foo", false)
    err.choices = [:foo, :bar]
    err.choose(:foo)
    assert_equal :foo, err.choice
  end

  test "#choose with string parameter" do
    err = Ethel::Error.new("foo", false)
    err.choices = [:foo => {:baz => :string}]
    err.choose(:foo, {:baz => "blah"})
    assert_equal [:foo, {:baz => "blah"}], err.choice
  end

  test "#choose with missing argument" do
    err = Ethel::Error.new("foo", false)
    err.choices = [:foo => {:baz => :string}]
    assert_raises(Ethel::InvalidChoice) do
      err.choose(:foo)
    end
  end

  test "#choose with wrong argument type" do
    err = Ethel::Error.new("foo", false)
    err.choices = [:foo => {:baz => :string}]
    assert_raises(Ethel::InvalidChoice) do
      err.choose(:foo, {:baz => 123})
    end
  end

  test "#choose with non-hash args" do
    err = Ethel::Error.new("foo", false)
    err.choices = [:foo]
    assert_raises(ArgumentError) do
      err.choose(:foo, 123)
    end
  end
end
