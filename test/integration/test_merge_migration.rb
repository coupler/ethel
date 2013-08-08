require 'helper'

class TestMergeMigration < Test::Unit::TestCase
  include IntegrationHelper

  io_test "merging fields from csv source" do
    source = Ethel::Readers::CSV.new(:string => "id,baz,qux\n1,one,uno\n2,two,dos")
    data = [
      {'id' => '1', 'foo' => 'stuff', 'bar' => '123'},
      {'id' => '2', 'foo' => 'junk', 'bar' => '456'}
    ]
    expected = [
      {'id' => '1', 'foo' => 'stuff', 'bar' => '123', 'baz' => 'one', 'qux' => 'uno'},
      {'id' => '2', 'foo' => 'junk', 'bar' => '456', 'baz' => 'two', 'qux' => 'dos'}
    ]
    migrate(data, expected) do |m|
      m.merge(source, 'id')
    end
  end

  io_test "merging fields from memory source" do
    source = Ethel::Adapters::Memory::Reader.new(:data => [
      {'id' => '1', 'baz' => 'one', 'qux' => 'uno'},
      {'id' => '2', 'baz' => 'two', 'qux' => 'dos'}
    ])
    data = [
      {'id' => '1', 'foo' => 'stuff', 'bar' => '123'},
      {'id' => '2', 'foo' => 'junk', 'bar' => '456'}
    ]
    expected = [
      {'id' => '1', 'foo' => 'stuff', 'bar' => '123', 'baz' => 'one', 'qux' => 'uno'},
      {'id' => '2', 'foo' => 'junk', 'bar' => '456', 'baz' => 'two', 'qux' => 'dos'}
    ]
    migrate(data, expected) do |m|
      m.merge(source, 'id')
    end
  end
end
