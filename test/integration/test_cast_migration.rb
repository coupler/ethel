require 'helper'

class TestCastMigration < Test::Unit::TestCase
  test "casting integer from csv to csv" do
    reader = Ethel::Readers::CSV.new(:string => "foo,bar\nstuff,123")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader, writer)
    migration.cast('foo', :integer)
    migration.cast('bar', :integer)
    migration.run
    assert_equal "foo,bar\n0,123\n", writer.data
  end
end
