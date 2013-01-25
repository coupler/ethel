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

  test "fields" do
    klass = new_subclass do
      def schema
        [['foo', {:type => :string}], ['bar', {:type => :string}]]
      end
    end
    source = klass.new

    field_1 = stub('field 1')
    Ethel::Field.expects(:new).with('foo', {:type => :string}).returns(field_1)
    field_2 = stub('field 2')
    Ethel::Field.expects(:new).with('bar', {:type => :string}).returns(field_2)
    assert_equal({'foo' => field_1, 'bar' => field_2}, source.fields)
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
