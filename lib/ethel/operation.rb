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
      @pre_operations = []
      @post_operations = []
    end

    protected

    def perform_setup(dataset)
      dataset = @pre_operations.inject(dataset) do |dataset, pre_operation|
        pre_operation.setup(dataset)
      end
      dataset = yield(dataset)
      @post_operations.inject(dataset) do |dataset, post_operation|
        post_operation.setup(dataset)
      end
    end

    def perform_transform(row)
      row = @pre_operations.inject(row) do |row, pre_operation|
        pre_operation.transform(row)
      end
      row = yield(row)
      @post_operations.inject(row) do |row, post_operation|
        post_operation.transform(row)
      end
    end

    def add_pre_operation(operation)
      @pre_operations << operation
    end

    def add_post_operation(operation)
      @post_operations << operation
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
