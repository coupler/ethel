require 'helper'

class TestWriter < Test::Unit::TestCase
  test "#add_row raises NotImplementedError" do
    writer = Ethel::Writer.new
    assert_raises(NotImplementedError) do
      writer.add_row({'foo' => 123})
    end
  end
end
