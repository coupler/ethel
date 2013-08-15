require 'helper'

class TestRenameMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test("removing a field") do
    data = [{'foo' => '456', 'bar' => '123'}]
    expected = [{'foo' => '456'}]
    migrate(data, expected) do |m|
      m.remove_field('bar')
    end
  end
end
