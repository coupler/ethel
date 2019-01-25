module Ethel
  module Operations
    class Merge < Operation
      def initialize(target_reader, options = {})
        super
        @target_reader = target_reader

        origin_fields = target_fields = []
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

        if origin_fields.empty? || target_fields.empty?
          raise "origin and target fields must be specified"
        end

        origin_fields = origin_fields.is_a?(Array) ? origin_fields : [origin_fields]
        target_fields = target_fields.is_a?(Array) ? target_fields : [target_fields]
        if origin_fields.length != target_fields.length
          raise ArgumentError, "origin and target fields must be the same length"
        end

        @origin_fields = origin_fields.collect do |field|
          field = process_field(field)
          if field[:name] != field[:alias]
            rename = Operation["rename"].new(field[:name], field[:alias])
            add_pre_operation(rename)
          end
          field
        end
        @target_fields = target_fields.collect do |field|
          field = process_field(field)
          if field[:name] != field[:alias]
            rename = Operation["rename"].new(field[:name], field[:alias])
            add_post_operation(rename)
          end
          field
        end

        if options.has_key?(:join_reader)
          @joins = {}
          origin_names = @origin_fields.collect { |f| f[:alias] }
          target_names = @target_fields.collect { |f| f[:alias] }
          options[:join_reader].each_row do |row|
            origin_keys = row.values_at(*origin_names)
            @joins[origin_keys] ||= []
            @joins[origin_keys].push(row.values_at(*target_names))
          end
        end
      end

      def setup(dataset)
        perform_setup(dataset) do |dataset|
          other = Dataset.new
          @target_reader.read(other)

          target_names = @target_fields.collect { |f| f[:name] }
          other.each_field do |field|
            if !target_names.include?(field.name)
              dataset.add_field(field)
            end
          end
          dataset
        end
      end

      def transform(row)
        perform_transform(row) do |row|
          target_names = @target_fields.collect { |f| f[:name] }

          if @joins
            origin_names = @origin_fields.collect { |f| f[:alias] }
            origin_keys = row.values_at(*origin_names)
            row_joins = @joins[origin_keys]
            @target_reader.each_row do |target_row|
              target_keys = target_row.values_at(*target_names)
              if row_joins.include?(target_keys)
                row = row.merge(target_row)
                break
              end
            end
          else
            origin_names = @origin_fields.collect { |f| f[:name] }
            origin_keys = row.values_at(*origin_names)
            @target_reader.each_row do |target_row|
              target_keys = target_row.values_at(*target_names)
              if origin_keys == target_keys
                row = row.merge(target_row.reject { |k, v| target_names.include?(k) })
                break
              end
            end
          end
          row
        end
      end

      private

      def process_field(field)
        case field
        when String
          { :name => field, :alias => field }
        when Hash
          field
        end
      end

      register('merge', self)
    end
  end
end
