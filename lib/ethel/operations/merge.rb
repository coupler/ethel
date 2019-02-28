module Ethel
  module Operations
    class Merge < Operation
      def initialize(target_reader, options = {})
        super
        @target_reader = target_reader
        is_join = options.has_key?(:join_reader)

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

        @origin_fields = origin_fields.collect.with_index do |field, i|
          field = process_field(field, "__origin_field_#{i}")

          # rename join field to something obscure to prevent conflicts
          op = Operation["rename"].new(field[:name], field[:tmp])
          add_pre_operation(op)

          op =
            if field[:name] != field[:alias]
              Operation["rename"].new(field[:tmp], field[:alias])
            else
              Operation["rename"].new(field[:tmp], field[:name])
            end
          add_post_operation(op)

          field
        end

        @target_pre_operations = []
        @target_fields = target_fields.collect.with_index do |field, i|
          field = process_field(field, "__target_field_#{i}")

          # rename join field to something obscure to prevent conflicts
          op = Operation["rename"].new(field[:name], field[:tmp])
          @target_pre_operations.push(op)

          if is_join
            op =
              if field[:name] != field[:alias]
                Operation["rename"].new(field[:tmp], field[:alias])
              else
                Operation["rename"].new(field[:tmp], field[:name])
              end
            add_post_operation(op)
          end

          field
        end

        if is_join
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
          target_names = @target_fields.collect { |f| f[:tmp] }
          origin_names = @origin_fields.collect { |f| f[:tmp] }
          origin_keys = row.values_at(*origin_names)

          if @joins
            row_joins = @joins[origin_keys]
            @target_reader.each_row do |target_row|
              target_row = perform_transform(target_row, @target_pre_operations, [])
              target_keys = target_row.values_at(*target_names)
              if row_joins.include?(target_keys)
                row = row.merge(target_row)
                break
              end
            end
          else
            @target_reader.each_row do |target_row|
              target_row = perform_transform(target_row, @target_pre_operations, [])
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

      def process_field(field, tmp_name)
        hsh =
          case field
          when String
            { :name => field, :alias => field }
          when Hash
            field
          end
        hsh.merge(:tmp => tmp_name)
      end

      register('merge', self)
    end
  end
end
