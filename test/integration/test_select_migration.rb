require 'helper'

class TestSelectMigration < Test::Unit::TestCase
  test "selecting fields from csv to csv" do
    reader = Ethel::Readers::CSV.new(:string => "foo,bar,baz\nstuff,123,junk")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader, writer)
    migration.select('foo', 'baz')
    migration.run
    assert_equal "foo,baz\nstuff,junk\n", writer.data
  end
end
