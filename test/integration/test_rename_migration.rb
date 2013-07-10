require 'helper'

class TestRenameMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test("renaming a field") do
    data = [{'foo' => '456'}]
    expected = [{'bar' => '456'}]
    migrate(data, expected) do |m|
      m.rename('foo', 'bar')
    end
  end
end
