require 'helper'

class TestCastMigration < Test::Unit::TestCase
  test "casting integer from csv to csv" do
    source = Ethel::Sources::CSV.new(:string => "foo,bar\nstuff,123")
    target = Ethel::Targets::CSV.new(:string => true)
    migration = Ethel::Migration.new(source, target)
    migration.cast(source.fields['foo'], :integer)
    migration.cast(source.fields['bar'], :integer)
    migration.run
    assert_equal "foo,bar\n0,123\n", target.data
  end
end
