module Ethel
  class Operation
    @@operations = {}
    def self.register(name, klass)
      @@operations[name] = klass
    end

    def self.[](name)
      @@operations[name]
    end

    def initialize(*args)
      @child_operations = []
    end

    def setup(dataset)
      @child_operations.each do |child_operation|
        child_operation.setup(dataset)
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
require 'ethel/operations/remove_field'
require 'ethel/operations/select'
require 'ethel/operations/cast'
require 'ethel/operations/rename'
require 'ethel/operations/update'
require 'ethel/operations/merge'
require 'ethel/operations/join'
