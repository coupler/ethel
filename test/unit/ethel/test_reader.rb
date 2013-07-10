require 'helper'

class TestReader < Test::Unit::TestCase
  def setup
    @original_readers = Ethel::Reader.class_variable_get(:@@readers)
  end

  def teardown
    Ethel::Reader.class_variable_set(:@@readers, @original_readers)
  end

  def new_subclass(&block)
    Class.new(Ethel::Reader, &block)
  end

  test "registering a reader" do
    klass = new_subclass
    Ethel::Reader.register('foo', klass)
    assert_equal klass, Ethel::Reader['foo']
  end

  test "#each_row raises NotImplementedError" do
    reader = Ethel::Reader.new
    assert_raises(NotImplementedError) do
      reader.each_row { |row| }
    end
  end

  test "#read raises NotImplementedError" do
    reader = Ethel::Reader.new
    dataset = stub('dataset')
    assert_raises(NotImplementedError) do
      reader.read(dataset)
    end
  end
end
