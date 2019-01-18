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

  test "#perform_setup chains pre operations" do
    pre_op = stub('pre-operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_pre_operation(pre_op)
      end
      define_method(:setup) do |dataset|
        perform_setup(dataset) do |arg|
          dataset
        end
      end
    end
    op = klass.new

    dataset = stub('dataset')
    pre_op.expects(:setup).with(dataset).returns(dataset)
    assert_same(op.setup(dataset), dataset)
  end

  test "#perform_setup chains post operations" do
    post_op = stub('post-operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_post_operation(post_op)
      end
      define_method(:setup) do |dataset|
        perform_setup(dataset) do |arg|
          dataset
        end
      end
    end
    op = klass.new

    dataset = stub('dataset')
    post_op.expects(:setup).with(dataset).returns(dataset)
    assert_same(op.setup(dataset), dataset)
  end

  test "#perform_transform chains pre operations" do
    pre_op = stub('pre-operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_pre_operation(pre_op)
      end
      define_method(:transform) do |row|
        perform_transform(row) do
          row
        end
      end
    end
    op = klass.new

    row = stub('row')
    pre_op.expects(:transform).with(row).returns(row)
    assert_same(op.transform(row), row)
  end

  test "#perform_transform chains post operations" do
    post_op = stub('post-operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_post_operation(post_op)
      end
      define_method(:transform) do |row|
        perform_transform(row) do
          row
        end
      end
    end
    op = klass.new

    row = stub('row')
    post_op.expects(:transform).with(row).returns(row)
    assert_same(op.transform(row), row)
  end
end
