require 'helper'

class TestCopyMigration < Test::Unit::TestCase
  test "copying from csv to csv" do
    source = Ethel::Sources::CSV.new(:string => "foo,bar\nstuff,123")
    target = Ethel::Targets::CSV.new(:string => true)
    migration = Ethel::Migration.new(source, target)
    migration.copy(source.fields['foo'])
    migration.copy(source.fields['bar'])
    migration.run
    assert_equal "foo,bar\nstuff,123\n", target.data
  end
end
