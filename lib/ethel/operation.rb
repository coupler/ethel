module Ethel
  class Operation
    def initialize(*args)
      @child_operations = []
    end

    def before_transform(source, target)
      @child_operations.each do |child_operation|
        child_operation.before_transform(source, target)
      end
    end

    def transform(row)
      @child_operations.inject(row) do |row, child_operation|
        child_operation.transform(row)
      end
    end

    protected

    def add_child_operation(operation)
      @child_operations << operation
    end
  end
end

require 'ethel/operations/add_field'
require 'ethel/operations/copy'
require 'ethel/operations/cast'
