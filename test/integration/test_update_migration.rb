require 'helper'

class TestUpdateMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test "update a field's values" do
    data = [{'foo' => 'stuff', 'bar' => '123'}]
    expected = [{'foo' => '456', 'bar' => '123'}]
    migrate(data, expected) do |m|
      m.update('foo', '456')
    end
  end

  io_test "update a field's values with filter" do
    data = [
      {'foo' => '123', 'bar' => 'baz'},
      {'foo' => '456', 'bar' => 'baz'}
    ]
    expected = [
      {'foo' => '123', 'bar' => 'baz'},
      {'foo' => '321', 'bar' => 'baz'}
    ]
    migrate(data, expected) do |m|
      m.update('foo', '321') { |row| row['foo'].to_i > 200 }
    end
  end

  io_test "update a field's value with block" do
    data = [
      {'foo' => '123', 'bar' => 'baz'},
      {'foo' => '456', 'bar' => 'baz'}
    ]
    expected = [
      {'foo' => '123', 'bar' => 'baz'},
      {'foo' => '321', 'bar' => 'baz'}
    ]
    migrate(data, expected) do |m|
      m.update('foo') { |row| row['foo'].to_i > 200 ? '321' : row['foo'] }
    end
  end
end
