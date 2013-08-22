require 'helper'

module TestAdapters
  module TestMemory
    class TestReader < Test::Unit::TestCase
      include ConstantsHelper
      scope Ethel::Adapters

      test "subclass of Reader" do
        assert_equal Reader, Memory::Reader.superclass
      end

      test "#read array of hashes" do
        reader = Memory::Reader.new(:data => [{'foo' => 123}, {'foo' => 456}])

        dataset = stub('dataset')
        field = stub('field')
        Field.expects(:new).with('foo', :type => :integer).returns(field)
        dataset.expects(:add_field).with(field)
        reader.read(dataset)
      end

      test "#read with inconsistent names" do
        reader = Memory::Reader.new(:data => [{'foo' => 123}, {'bar' => 456}])

        dataset = stub('dataset')
        assert_raises(InvalidFieldName) do
          reader.read(dataset)
        end
      end

      test "#read with inconsistent values" do
        reader = Memory::Reader.new(:data => [{'foo' => 123}, {'foo' => 'bar'}])

        dataset = stub('dataset')
        assert_raises(InvalidFieldType) do
          reader.read(dataset)
        end
      end

      test "#read with nil value first" do
        reader = Memory::Reader.new(:data => [{'foo' => nil}, {'foo' => 456}])

        dataset = stub('dataset')
        field = stub('field')
        Field.expects(:new).with('foo', :type => :integer).returns(field)
        dataset.expects(:add_field).with(field)
        reader.read(dataset)
      end

      test "#read with nil value second" do
        reader = Memory::Reader.new(:data => [{'foo' => 456}, {'foo' => nil}])

        dataset = stub('dataset')
        field = stub('field')
        Field.expects(:new).with('foo', :type => :integer).returns(field)
        dataset.expects(:add_field).with(field)
        reader.read(dataset)
      end

      test "#read with all nil values" do
        reader = Memory::Reader.new(:data => [{'foo' => nil}, {'foo' => nil}])
        dataset = stub('dataset')
        assert_raises(InvalidFieldType) do
          reader.read(dataset)
        end
      end

      test "#read with manually specified field types" do
        reader = Memory::Reader.new({
          :data => [{'foo' => nil}, {'foo' => nil}],
          :field_types => {'foo' => :integer}
        })

        dataset = stub('dataset')
        field = stub('field')
        Field.expects(:new).with('foo', :type => :integer).returns(field)
        dataset.expects(:add_field).with(field)
        reader.read(dataset)
      end

      test "#read with manually specified field types and inconsistent names" do
        reader = Memory::Reader.new({
          :data => [{'foo' => 123}, {'bar' => 456}],
          :field_types => {'foo' => :integer}
        })

        dataset = stub('dataset')
        assert_raises(InvalidFieldName) do
          reader.read(dataset)
        end
      end

      test "#each_row" do
        reader = Memory::Reader.new(:data => [{'foo' => 123}, {'foo' => 456}])
        reader.to_enum(:each_row).with_index do |row, i|
          case i
          when 0
            assert_equal({'foo' => 123}, row)
          when 1
            assert_equal({'foo' => 456}, row)
          end
        end
      end

      test "registers itself" do
        assert_equal Memory::Reader, Reader['memory']
      end
    end
  end
end
