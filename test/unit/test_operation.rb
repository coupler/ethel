require 'helper'

class TestOperation < Test::Unit::TestCase
  def new_subclass(&block)
    Class.new(Ethel::Operation, &block)
  end

end
