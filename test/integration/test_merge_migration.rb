require 'helper'

class TestMergeMigration < Test::Unit::TestCase
  test "merging fields from csv to csv" do
    reader_1 = Ethel::Readers::CSV.new(:string => "id,foo,bar\n1,stuff,123\n2,junk,456")
    reader_2 = Ethel::Readers::CSV.new(:string => "id,baz,qux\n1,one,uno\n2,two,dos")
    writer = Ethel::Writers::CSV.new(:string => true)
    migration = Ethel::Migration.new(reader_1, writer)
    migration.merge(reader_2, 'id')
    migration.run
    assert_equal "id,foo,bar,baz,qux\n1,stuff,123,one,uno\n2,junk,456,two,dos\n", writer.data
  end
end
