module Ethel
  class Migration
    def initialize(reader, writer)
      @reader = reader
      @writer = writer
      @operations = []

      @dataset = Dataset.new
      @reader.read(@dataset)
    end

    def run
      @writer.prepare(@dataset)

      @reader.each_row do |row|
        row = @operations.inject(row) { |r, op| op.transform(r) }
        @writer.add_row(row)
      end
      @writer.flush
    end

    def method_missing(name, *args, &block)
      klass = Operation.operation(name.to_s)
      if klass
        op = klass.new(*args, &block)
        add_operation(op)
      else
        super
      end
    end

    protected

    def add_operation(op)
      op.setup(@dataset)
      @operations << op
    end
  end
end
