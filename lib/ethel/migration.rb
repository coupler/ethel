module Ethel
  class Migration
    def initialize(source, target)
      @source = source
      @target = target
      @operations = []
    end

    def copy(field)
      @operations << Operations::Copy.new(field)
    end

    def cast(field, type)
      @operations << Operations::Cast.new(field, type)
    end

    def run
      @operations.each do |operation|
        operation.before_transform(@source, @target)
      end
      @target.prepare

      @source.each do |row|
        row = @operations.inject(row) { |r, op| op.transform(r) }
        @target.add_row(row)
      end
      @target.flush
    end
  end
end
