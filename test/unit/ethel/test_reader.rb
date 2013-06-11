require 'helper'

class TestReader < Test::Unit::TestCase
  test "#each_row raises NotImplementedError" do
    reader = Ethel::Reader.new
    assert_raises(NotImplementedError) do
      reader.each_row { |row| }
    end
  end

  test "#read raises NotImplementedError" do
    reader = Ethel::Reader.new
    dataset = stub('dataset')
    assert_raises(NotImplementedError) do
      reader.read(dataset)
    end
  end
end
