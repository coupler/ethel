module Ethel
  module Adapters
    module CSV
      class Writer < ::Ethel::Writer
        def initialize(options)
          if !options.has_key?(:string) && !options.has_key?(:file)
            raise "either the :file or :string option must be specified"
          end
          @options = options
          @csv_options = options[:csv_options] ||= {}
          @field_names = []
        end

        def prepare(dataset)
          @date_field_indexes = []
          dataset.each_field.with_index do |field, i|
            @field_names << field.name

            implicit_conversion = true

            case field.type
            when :string
              implicit_conversion = false
            when :date
              if @options.has_key?(:date_format)
                implicit_conversion = false
                @date_field_indexes << i
              end
            end

            if implicit_conversion
              warn "CSV WARNING: implicit conversion from #{field.type} to string for field '#{field.name}'"
            end
          end

          csv_options = @csv_options.merge({
            :headers => @field_names, :write_headers => true
          })
          @csv =
            if @options[:file]
              ::CSV.open(@options[:file], 'wb', csv_options)
            elsif @options[:string]
              @data = ""
              ::CSV.new(@data, csv_options)
            end
        end

        def add_row(row)
          # pre-process row for types that need to be converted
          row = row.values_at(*@field_names)
          @date_field_indexes.each do |i|
            next unless row[i].is_a?(Date)
            row[i] = row[i].strftime(@options[:date_format])
          end

          @csv << row
        end

        def flush
          @csv.close
        end

        def data
          if @options[:string]
            @data
          end
        end

        ::Ethel::Writer.register('csv', self)
      end
    end
  end
end
