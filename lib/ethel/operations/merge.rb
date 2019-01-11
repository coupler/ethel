module Ethel
  module Operations
    class Merge < Operation
      def initialize(reader, options = {})
        super
        @reader = reader

        origin_fields = target_fields = nil
        if options.has_key?(:fields)
          origin_fields = target_fields = options[:fields]
        elsif options.has_key?(:origin_fields)
          origin_fields = options[:origin_fields]
          if options.has_key?(:target_fields)
            target_fields = options[:target_fields]
          else
            target_fields = origin_fields
          end
        end

        @origin_fields = origin_fields.is_a?(Array) ? origin_fields : [origin_fields]
        @target_fields = target_fields.is_a?(Array) ? target_fields : [target_fields]
        if @origin_fields.length != @target_fields.length
          raise ArgumentError, "origin and target fields must be the same length"
        end
      end

      def setup(dataset)
        super

        other = Dataset.new
        @reader.read(other)
        other.each_field do |field|
          if !@target_fields.include?(field.name)
            dataset.add_field(field)
          end
        end
      end

      def transform(row)
        row = super

        origin_keys = row.values_at(*@origin_fields)
        @reader.each_row do |merge_row|
          target_keys = merge_row.values_at(*@target_fields)
          if origin_keys == target_keys
            row = row.merge(merge_row.reject { |k, v| @target_fields.include?(k) })
            break
          end
        end

        row
      end

      register('merge', self)
    end
  end
end
