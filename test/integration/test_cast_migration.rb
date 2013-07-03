require 'helper'

class TestCastMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test("casting string to integer", %w{memory memory}, %w{csv memory}) do
    data = [{'foo' => '456'}]
    expected = [{'foo' => 456}]
    migrate(data, expected) do |m|
      m.cast('foo', :integer)
    end
  end

  io_test("casting integer to string", %w{memory memory}, %w{memory csv}) do
    data = [{'foo' => 456}]
    expected = [{'foo' => '456'}]
    migrate(data, expected) do |m|
      m.cast('foo', :string)
    end
  end
end
