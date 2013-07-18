module Ethel
  class Migration
    attr_reader :reader, :writer

    def initialize(reader, writer)
      @reader = reader
      @writer = writer
      @operations = []

      @dataset = Dataset.new
      @reader.read(@dataset)
    end

    def run
      if @operations.empty?
        @writer.prepare(@dataset)
        @reader.each_row do |row|
          @writer.add_row(row)
        end
        @writer.flush
      else
        # If there is only one operation, we read directly from the
        # reader and write directly to the writer. However, if there
        # is more than one operation, intermediary memory
        # readers/writers are used.
        reader = @reader
        last = @operations.length - 1
        0.upto(last) do |i|
          op = @operations[i]
          op.setup(@dataset)

          writer =
            if i == last
              @writer
            else
              Writers::Memory.new
            end
          writer.prepare(@dataset)

          reader.each_row do |row|
            row = op.transform(row)
            @dataset.validate_row(row)
            writer.add_row(row)
          end
          writer.flush

          if i < last
            reader = Readers::Memory.new(writer.data)
          end
        end
      end
    end

    def method_missing(name, *args, &block)
      klass = Operation[name.to_s]
      if klass
        op = klass.new(*args, &block)
        add_operation(op)
      else
        super
      end
    end

    protected

    def add_operation(op)
      # FIXME: We need an immediate check to see if the operation
      # is valid for the current state of the dataset. Also, is
      # the transformation valid? We could run some test data
      # through it and find out. This way the migration doesn't
      # die after an expensive operation has already taken place.
      # An other option is to have wrap operations in
      # "transactions". If an operation fails, we can save the
      # state of the data in memory or something and the migration
      # can be resumed when the user has fixed the problem.

      @operations << op
    end
  end
end
