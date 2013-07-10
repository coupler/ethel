require 'helper'

class TestOperation < Test::Unit::TestCase
  def setup
    @original_operations = Ethel::Operation.class_variable_get(:@@operations)
  end

  def teardown
    Ethel::Operation.class_variable_set(:@@operations, @original_operations)
  end

  def new_subclass(&block)
    Class.new(Ethel::Operation, &block)
  end

  test "registering an operation" do
    klass = new_subclass
    Ethel::Operation.register('foo', klass)
    assert_equal klass, Ethel::Operation['foo']
  end

  test "#setup chains child operations" do
    child = stub('child operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_child_operation(child)
      end
    end
    op = klass.new

    dataset = stub('dataset')
    child.expects(:setup).with(dataset)
    op.setup(dataset)
  end

  test "#transform chains child operations" do
    child = stub('child operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_child_operation(child)
      end
    end
    op = klass.new

    child.expects(:transform).with({'foo' => 'bar'}).returns({'foo' => 123})
    assert_equal({'foo' => 123}, op.transform({'foo' => 'bar'}))
  end
end
