require 'helper'

class TestMigration < Test::Unit::TestCase
  def setup
    @reader = stub('reader')
    @writer = stub('writer')
    Ethel::Operations::Cast.stubs(:new)
    Ethel::Operations::Update.stubs(:new)
  end

  test "simple conversion (no operations)" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    seq = SequenceHelper.new('run sequence')
    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end

  test "casting a field" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    cast_operation = stub('cast operation')
    Ethel::Operations::Cast.expects(:new).with('foo', :integer).
      returns(cast_operation)
    m.cast('foo', :integer)

    seq = SequenceHelper.new('run sequence')
    seq << cast_operation.expects(:setup).with(dataset)
    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << cast_operation.expects(:transform).with(row).returns(row)
    seq << dataset.expects(:validate_row).with(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end

  test "multi-operation migration" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    cast_operation_1 = stub('cast operation 1')
    Ethel::Operations::Cast.expects(:new).with('foo', :integer).
      returns(cast_operation_1)
    m.cast('foo', :integer)

    cast_operation_2 = stub('cast operation 2')
    Ethel::Operations::Cast.expects(:new).with('bar', :integer).
      returns(cast_operation_2)
    m.cast('bar', :integer)

    seq = SequenceHelper.new('run sequence')
    memwriter = stub('memory writer')
    write_data = stub('write data')
    memreader = stub('memory reader')
    row = stub('row')
    new_row = stub('new row')

    # round 1
    seq << cast_operation_1.expects(:setup).with(dataset)
    seq << Ethel::Writers::Memory.expects(:new).returns(memwriter)
    seq << memwriter.expects(:prepare).with(dataset)
    seq << @reader.expects(:each_row).yields(row)
    seq << cast_operation_1.expects(:transform).with(row).returns(new_row)
    seq << dataset.expects(:validate_row).with(new_row)
    seq << memwriter.expects(:add_row).with(new_row)
    seq << memwriter.expects(:flush)

    # round 2
    seq << memwriter.expects(:data).returns(write_data)
    seq << Ethel::Readers::Memory.expects(:new).with(:data => write_data).returns(memreader)
    seq << cast_operation_2.expects(:setup).with(dataset)
    seq << @writer.expects(:prepare).with(dataset)
    seq << memreader.expects(:each_row).yields(row)
    seq << cast_operation_2.expects(:transform).with(row).returns(new_row)
    seq << dataset.expects(:validate_row).with(new_row)
    seq << @writer.expects(:add_row).with(new_row)
    seq << @writer.expects(:flush)

    m.run
  end

  test "updating a field" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    update_operation = stub('update operation')
    Ethel::Operations::Update.expects(:new).with('foo', 123).
      returns(update_operation)
    update_operation.expects(:setup).with(dataset)
    m.update('foo', 123)

    seq = SequenceHelper.new('run sequence')

    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << update_operation.expects(:transform).with(row).returns(row)
    seq << dataset.expects(:validate_row).with(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end

  test "selecting fields" do
    dataset = stub('dataset')
    Ethel::Dataset.expects(:new).returns(dataset)
    @reader.expects(:read).with(dataset)
    m = Ethel::Migration.new(@reader, @writer)

    select_operation = stub('select operation')
    Ethel::Operations::Select.expects(:new).with('foo', 'bar').
      returns(select_operation)
    select_operation.expects(:setup).with(dataset)
    m.select('foo', 'bar')

    seq = SequenceHelper.new('run sequence')

    seq << @writer.expects(:prepare).with(dataset)
    row = stub('row')
    seq << @reader.expects(:each_row).yields(row)
    seq << select_operation.expects(:transform).with(row).returns(row)
    seq << dataset.expects(:validate_row).with(row)
    seq << @writer.expects(:add_row).with(row)
    seq << @writer.expects(:flush)
    m.run
  end
end
