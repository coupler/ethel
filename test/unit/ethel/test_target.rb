require 'helper'

class TestTarget < Test::Unit::TestCase
  def new_subclass(&block)
    Class.new(Ethel::Target, &block)
  end

  test "#add_field raises NotImplementedError" do
    klass = new_subclass
    target = klass.new
    assert_raises(NotImplementedError) { target.add_field('foo') }
  end

  test "#add_row raises NotImplementedError" do
    klass = new_subclass
    target = klass.new
    assert_raises(NotImplementedError) { target.add_row('foo') }
  end

  test "#flush is a no-op" do
    klass = new_subclass
    target = klass.new
    assert_nothing_raised { target.flush }
  end

  test "#data returns nil" do
    klass = new_subclass
    target = klass.new
    assert_nil target.data
  end

  test "#prepare is a no-op" do
    klass = new_subclass
    target = klass.new
    assert_nothing_raised { target.prepare }
  end
end
