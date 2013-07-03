require 'helper'

class TestSelectMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test "selecting fields" do
    data = [{'foo' => 'stuff', 'bar' => '123', 'baz' => 'junk'}]
    expected = [{'foo' => 'stuff', 'baz' => 'junk'}]
    migrate(data, expected) do |m|
      m.select('foo', 'baz')
    end
  end
end
