require 'helper'

class TestUpdateMigration < Test::Unit::TestCase
  test "update a field's values" do
    reader = Ethel::Readers::CSV.new(:string => "foo,bar\nstuff,123")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader, writer)
    migration.update('foo', '456')
    migration.run
    assert_equal "foo,bar\n456,123\n", writer.data
  end

  test "update a field's value with filter" do
    reader = Ethel::Readers::CSV.new(:string => "foo,bar\n123,baz\n456,baz")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader, writer)
    migration.update('foo', '321') { |v| v.to_i > 200 }
    migration.run
    assert_equal "foo,bar\n123,baz\n321,baz\n", writer.data
  end

  test "update a field's value with block" do
    reader = Ethel::Readers::CSV.new(:string => "foo,bar\n123,baz\n456,baz")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader, writer)
    migration.update('foo') { |v| v.to_i > 200 ? '321' : v }
    migration.run
    assert_equal "foo,bar\n123,baz\n321,baz\n", writer.data
  end
end
