require 'helper'

class TestUpdateMigration < Test::Unit::TestCase
  test "update a field's values" do
    source = Ethel::Sources::CSV.new(:string => "foo,bar\nstuff,123")
    target = Ethel::Targets::CSV.new(:string => true)
    migration = Ethel::Migration.new(source, target)
    migration.update(source.fields['foo'], '456')
    migration.run
    assert_equal "foo\n456\n", target.data
  end

  test "update a field's value with filter" do
    source = Ethel::Sources::CSV.new(:string => "foo,bar\n123,baz\n456,baz")
    target = Ethel::Targets::CSV.new(:string => true)
    migration = Ethel::Migration.new(source, target)
    migration.update(source.fields['foo'], '321') { |v| v.to_i > 200 }
    migration.run
    assert_equal "foo\n123\n321\n", target.data
  end

  test "update a field's value with block" do
    source = Ethel::Sources::CSV.new(:string => "foo,bar\n123,baz\n456,baz")
    target = Ethel::Targets::CSV.new(:string => true)
    migration = Ethel::Migration.new(source, target)
    migration.update(source.fields['foo']) { |v| v.to_i > 200 ? '321' : v }
    migration.run
    assert_equal "foo\n123\n321\n", target.data
  end
end
