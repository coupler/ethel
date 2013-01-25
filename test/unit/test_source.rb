require 'helper'

class TestSource < Test::Unit::TestCase
  def new_subclass(&block)
    Class.new(Ethel::Source, &block)
  end

  test "schema raises NotImplementedError" do
    klass = new_subclass
    source = klass.new
    assert_raises(NotImplementedError) { source.schema }
  end

  test "field_names" do
    klass = new_subclass do
      def schema
        [['foo', {}], ['bar', {}]]
      end
    end
    source = klass.new
    assert_equal %w{foo bar}, source.field_names
  end

  test "each raises NotImplementedError" do
    klass = new_subclass
    source = klass.new
    assert_raises(NotImplementedError) { source.each }
  end

  test "includes Enumerable" do
    assert_include Ethel::Source.included_modules, Enumerable
  end

  test "all" do
    klass = new_subclass do
      def each
        yield({'foo' => 1, 'bar' => 2})
        yield({'foo' => 3, 'bar' => 4})
      end
    end
    source = klass.new
    assert_equal [{'foo' => 1, 'bar' => 2}, {'foo' => 3, 'bar' => 4}],
      source.all
  end
end
