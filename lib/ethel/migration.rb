module Ethel
  class Migration
    def initialize(reader, writer)
      @reader = reader
      @writer = writer
      @operations = []

      @dataset = Dataset.new
      @reader.read(@dataset)
    end

    def cast(field_name, type)
      add_operation(Operations::Cast.new(@dataset.field(field_name), type))
    end

    def update(field_name, *args, &block)
      add_operation(Operations::Update.new(@dataset.field(field_name), *args, &block))
    end

    def run
      @writer.prepare(@dataset)

      @reader.each_row do |row|
        row = @operations.inject(row) { |r, op| op.transform(r) }
        @writer.add_row(row)
      end
      @writer.flush
    end

    protected

    def add_operation(op)
      op.setup(@dataset)
      @operations << op
    end
  end
end
