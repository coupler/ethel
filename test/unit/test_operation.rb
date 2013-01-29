require 'helper'

class TestOperation < Test::Unit::TestCase
  def new_subclass(&block)
    Class.new(Ethel::Operation, &block)
  end

  test "#before_transform chains child operations" do
    child = stub('child operation')
    klass = new_subclass do
      define_method(:initialize) do |*args|
        super(*args)
        add_child_operation(child)
      end
    end
    op = klass.new

    child.expects(:before_transform).with('foo', 'bar')
    op.before_transform('foo', 'bar')
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
