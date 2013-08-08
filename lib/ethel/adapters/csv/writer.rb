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
          dataset.each_field do |field|
            @field_names << field.name
            if field.type != :string
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
          @csv << row.values_at(*@field_names)
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
