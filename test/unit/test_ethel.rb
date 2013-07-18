require 'helper'

class TestEthel < Test::Unit::TestCase
  test "migrate helper" do
    reader_class = stub('reader class')
    Ethel::Reader.expects(:[]).with('foo').returns(reader_class)
    writer_class = stub('writer class')
    Ethel::Writer.expects(:[]).with('bar').returns(writer_class)

    reader = stub('reader')
    reader_class.expects(:new).with(:one => 'one', :two => 'two').returns(reader)
    writer = stub('writer')
    writer_class.expects(:new).with(:three => 'three', :four => 'four').returns(writer)

    migration = stub('migration')
    Ethel::Migration.expects(:new).with(reader, writer).returns(migration)

    yielded = false
    read_opts = {:type => 'foo', :one => 'one', :two => 'two'}
    write_opts = {:type => 'bar', :three => 'three', :four => 'four'}
    migration.expects(:run)
    Ethel.migrate(read_opts, write_opts) do |m|
      yielded = true
      assert_equal migration, m
    end
    assert yielded
  end
end
