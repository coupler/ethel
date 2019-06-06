module Ethel
  module Operations
    class Join < Operation
      def initialize(target_reader, join_reader, options = {})
        super
        @target_reader = target_reader
        @join_reader = join_reader

        if options.has_key?(:origin_fields)
          origin_join_fields = options[:origin_fields]
        else
          raise "origin fields must be specified"
        end

        if options.has_key?(:target_fields)
          target_join_fields = options[:target_fields]
        else
          raise "target fields must be specified"
        end

        if !origin_join_fields.is_a?(Array)
          origin_join_fields = [origin_join_fields]
        end
        if !target_join_fields.is_a?(Array)
          target_join_fields = [target_join_fields]
        end
        if origin_join_fields.length != target_join_fields.length
          raise ArgumentError, "origin and target fields must be the same length"
        end

        @origin_fields = {
          :join_names => [],
          :join_aliases => [],
          :names => [],
          :aliases => []
        }
        origin_join_fields.each do |field|
          field = process_field(field)
          @origin_fields[:join_names]   << field[:name]
          @origin_fields[:join_aliases] << field[:alias]
          @origin_fields[:names]        << field[:name]
          @origin_fields[:aliases]      << field[:alias]
        end

        @target_fields = {
          :join_names => [],
          :join_aliases => [],
          :names => [],
          :aliases => []
        }
        target_join_fields.each do |field|
          field = process_field(field)
          @target_fields[:join_names]   << field[:name]
          @target_fields[:join_aliases] << field[:alias]
          @target_fields[:names]        << field[:name]
          @target_fields[:aliases]      << field[:alias]
        end
      end

      def setup(origin_dataset)
        @setup_called = true

        # get dataset metadata from target reader
        target_dataset = Dataset.new
        @target_reader.read(target_dataset)

        # get key types of origin and target keys
        origin_key_types =
          @origin_fields[:join_names].collect do |name|
            field = origin_dataset.field(name, true)
            field.type
          end
        target_key_types =
          @target_fields[:join_names].collect do |name|
            field = target_dataset.field(name, true)
            field.type
          end

        # collect sets of join keys, using the origin and target aliases
        @joins = {}
        @join_reader.each_row do |row|
          origin_keys = row.values_at(*@origin_fields[:join_aliases])
          origin_keys.collect!.with_index do |value, i|
            Util.cast(value, origin_key_types[i])
          end
          @joins[origin_keys] ||= []

          target_keys = row.values_at(*@target_fields[:join_aliases])
          target_keys.collect!.with_index do |value, i|
            Util.cast(value, target_key_types[i])
          end
          @joins[origin_keys].push(target_keys)
        end

        # rename origin fields as necessary
        conflicting_names = []
        origin_fields = origin_dataset.each_field.to_a
        origin_fields.each do |origin_field|
          # possibly rename origin fields that are designated as join fields
          idx = @origin_fields[:join_names].index(origin_field.name)
          if !idx.nil?
            origin_join_alias = @origin_fields[:join_aliases][idx]
            if origin_field.name != origin_join_alias
              # if an origin field already exists with the same name as the
              # join alias, raise an error for now
              if origin_dataset.field(origin_join_alias)
                raise "origin join alias conflicts with existing origin field"
              end

              # rename field
              new_origin_field = Field.new(origin_join_alias, :type => origin_field.type)
              origin_dataset.alter_field(origin_field.name, new_origin_field)
            end
            next
          end

          target_field = target_dataset.field(origin_field.name)
          if target_field
            # conflict found; rename origin field
            conflicting_names << origin_field.name
            new_field_name = "origin_#{origin_field.name}"
            new_field = Field.new(new_field_name, :type => origin_field.type)
            origin_dataset.alter_field(origin_field.name, new_field)
            @origin_fields[:names] << origin_field.name
            @origin_fields[:aliases] << new_field_name
          else
            @origin_fields[:names] << origin_field.name
            @origin_fields[:aliases] << origin_field.name
          end
        end

        # add fields that are going to be merged into the origin dataset from
        # the target dataset
        target_dataset.each_field do |target_field|
          # check to see if this field is a join field
          idx = @target_fields[:join_names].index(target_field.name)
          if !idx.nil?
            # use specified alias
            new_field = Field.new(@target_fields[:join_aliases][idx], :type => target_field.type)
            origin_dataset.add_field(new_field)
            next
          end

          if conflicting_names.include?(target_field.name)
            # conflict found; add target field with new name
            new_field_name = "target_#{target_field.name}"
            new_field = Field.new(new_field_name, :type => target_field.type)
            origin_dataset.add_field(new_field)
            @target_fields[:names] << target_field.name
            @target_fields[:aliases] << new_field_name
          else
            # no conflict; just add the target field
            origin_dataset.add_field(target_field)
            @target_fields[:names] << target_field.name
            @target_fields[:aliases] << target_field.name
          end
        end
      end

      def transform(row)
        raise "must call setup before transform" if !@setup_called
        row = super

        origin_keys = row.values_at(*@origin_fields[:join_names])
        row_joins = @joins[origin_keys]
        if row_joins.nil?
          return :skip
        end

        target_row = nil
        @target_reader.each_row do |candidate_target_row|
          target_keys = candidate_target_row.values_at(*@target_fields[:join_names])
          next if !row_joins.include?(target_keys)

          # matching target row found
          target_row_keys = @target_fields[:aliases]
          target_row_values = candidate_target_row.values_at(*@target_fields[:names])
          target_row = Hash[target_row_keys.zip(target_row_values)]
          break
        end

        if target_row
          row_keys = @origin_fields[:aliases]
          row_values = row.values_at(*@origin_fields[:names])
          Hash[row_keys.zip(row_values)].merge(target_row)
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
