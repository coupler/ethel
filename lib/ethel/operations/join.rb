module Ethel
  module Operations
    class Join < Operation
      def initialize(target_reader, join_reader, options = {})
        super
        @target_reader = target_reader
        @join_reader = join_reader

        if options.has_key?(:origin_fields)
          origin_fields = options[:origin_fields]
        else
          raise "origin fields must be specified"
        end

        if options.has_key?(:target_fields)
          target_fields = options[:target_fields]
        else
          raise "target fields must be specified"
        end

        origin_fields = origin_fields.is_a?(Array) ? origin_fields : [origin_fields]
        target_fields = target_fields.is_a?(Array) ? target_fields : [target_fields]
        if origin_fields.length != target_fields.length
          raise ArgumentError, "origin and target fields must be the same length"
        end

        @origin_fields = []
        @origin_field_names = []
        @origin_field_aliases = []
        origin_fields.each do |field|
          field = process_field(field)
          @origin_fields << field
          @origin_field_names << field[:name]
          @origin_field_aliases << field[:alias]

          if field[:name] != field[:alias]
            op = Operation["rename"].new(field[:name], field[:alias])
            add_child_operation(op)
          end
        end

        @target_fields = []
        @target_field_names = []
        @target_field_aliases = []
        target_fields.each do |field|
          field = process_field(field)
          @target_fields << field
          @target_field_names << field[:name]
          @target_field_aliases << field[:alias]
        end

        target_dataset = Dataset.new
        @target_reader.read(target_dataset)

        target_dataset.each_field do |field|
          target_field = @target_fields.find { |tf| tf[:name] == field.name }
          op =
            if target_field
              Operation['add_field'].new(target_field[:alias], field.type)
            else
              Operation['add_field'].new(field.name, field.type)
            end
          add_child_operation(op)
        end

        # collect sets of join keys, using the origin and target aliases
        @joins = {}
        join_reader.each_row do |row|
          origin_keys = row.values_at(*@origin_field_aliases)
          @joins[origin_keys] ||= []
          @joins[origin_keys].push(row.values_at(*@target_field_aliases))
        end
      end

      # def setup(dataset)
      #   super
      # end

      def transform(row)
        row = super

        origin_keys = row.values_at(*@origin_field_aliases)
        row_joins = @joins[origin_keys]
        if row_joins.nil?
          return :skip
        end

        found = false
        @target_reader.each_row do |target_row|
          target_keys = target_row.values_at(*@target_field_names)
          if row_joins.include?(target_keys)
            found = true
            target_row = target_row.dup
            @target_fields.each do |field|
              target_row[field[:alias]] = target_row.delete(field[:name])
            end
            row = row.merge(target_row)
            break
          end
        end

        if found
          row
        else
          :skip
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

      register('join', self)
    end
  end
end
