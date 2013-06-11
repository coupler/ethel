require 'helper'

class TestMigration < Test::Unit::TestCase
  def setup
    @source = stub('source')
    @target = stub('target')
  end

  test "copying a field" do
    m = Ethel::Migration.new(@source, @target)

    field = stub('field')
    copy_operation = stub('copy operation')
    Ethel::Operations::Copy.expects(:new).with(field).returns(copy_operation)
    m.copy(field)

    seq = SequenceHelper.new('run sequence')
    row = stub('row')
    seq << copy_operation.expects(:before_transform).with(@source, @target)
    seq << @target.expects(:prepare)
    seq << @source.expects(:each).yields(row)
    seq << copy_operation.expects(:transform).with(row).returns(row)
    seq << @target.expects(:add_row).with(row)
    seq << @target.expects(:flush)
    m.run
  end

  test "casting a field" do
    m = Ethel::Migration.new(@source, @target)

    field = stub('field')
    cast_operation = stub('cast operation')
    Ethel::Operations::Cast.expects(:new).with(field, :integer).
      returns(cast_operation)
    m.cast(field, :integer)

    seq = SequenceHelper.new('run sequence')
    row = stub('row')
    seq << cast_operation.expects(:before_transform).with(@source, @target)
    seq << @target.expects(:prepare)
    seq << @source.expects(:each).yields(row)
    seq << cast_operation.expects(:transform).with(row).returns(row)
    seq << @target.expects(:add_row).with(row)
    seq << @target.expects(:flush)
    m.run
  end

  test "updating a field" do
    m = Ethel::Migration.new(@source, @target)

    field = stub('field')
    update_operation = stub('update operation')
    Ethel::Operations::Update.expects(:new).with(field, 123).
      returns(update_operation)
    m.update(field, 123)

    seq = SequenceHelper.new('run sequence')
    row = stub('row')
    seq << update_operation.expects(:before_transform).with(@source, @target)
    seq << @target.expects(:prepare)
    seq << @source.expects(:each).yields(row)
    seq << update_operation.expects(:transform).with(row).returns(row)
    seq << @target.expects(:add_row).with(row)
    seq << @target.expects(:flush)
    m.run
  end
end
