require 'helper'

class TestWriter < Test::Unit::TestCase
  def setup
    @original_writers = Ethel::Writer.instance_variable_get(:@subclasses)
  end

  def teardown
    Ethel::Writer.instance_variable_set(:@subclasses, @original_writers)
  end

  def new_subclass(&block)
    Class.new(Ethel::Writer, &block)
  end

  test "registering a writer" do
    klass = new_subclass
    Ethel::Writer.register('foo', klass)
    assert_equal klass, Ethel::Writer['foo']
  end

  test "#add_row raises NotImplementedError" do
    writer = Ethel::Writer.new
    assert_raises(NotImplementedError) do
      writer.add_row({'foo' => 123})
    end
  end
end
