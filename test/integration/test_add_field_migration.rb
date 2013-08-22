require 'helper'

class TestAddFieldMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test("adding a field") do
    data = [{'foo' => '456'}]
    expected = [{'foo' => '456', 'bar' => nil}]
    migrate(data, expected) do |m|
      m.add_field('bar', :string)
    end
  end
end
