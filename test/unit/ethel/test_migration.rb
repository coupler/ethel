require 'helper'

class TestMigration < Test::Unit::TestCase
  def setup
    @reader = stub('reader')
    @writer = stub('writer')
    Ethel::Operations::Cast.stubs(:new)
    Ethel::Operations::Update.stubs(:new)
  end

  test "casting a field" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    field = stub('field', :name => 'foo')
    dataset.expects(:field).with('foo').returns(field)
    cast_operation = stub('cast operation')
    Ethel::Operations::Cast.expects(:new).with(field, :integer).
      returns(cast_operation)
    cast_operation.expects(:setup).with(dataset)
    m.cast('foo', :integer)

    seq = SequenceHelper.new('run sequence')

    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << cast_operation.expects(:transform).with(row).returns(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end

  test "updating a field" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    field = stub('field')
    dataset.expects(:field).with('foo').returns(field)
    update_operation = stub('update operation')
    Ethel::Operations::Update.expects(:new).with(field, 123).
      returns(update_operation)
    update_operation.expects(:setup).with(dataset)
    m.update('foo', 123)

    seq = SequenceHelper.new('run sequence')

    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << update_operation.expects(:transform).with(row).returns(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end

  test "selecting fields" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    field_1 = stub('field 1')
    dataset.expects(:field).with('foo').returns(field_1)
    field_2 = stub('field 2')
    dataset.expects(:field).with('bar').returns(field_2)
    select_operation = stub('select operation')
    Ethel::Operations::Select.expects(:new).with(field_1, field_2).
      returns(select_operation)
    select_operation.expects(:setup).with(dataset)
    m.select('foo', 'bar')

    seq = SequenceHelper.new('run sequence')

    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << select_operation.expects(:transform).with(row).returns(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end
end
