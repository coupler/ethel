module Ethel
  module Targets
    class CSV < Target
      def initialize(options)
        @options = options
        @fields = []
        @rows = []
      end

      def add_field(field)
        @fields << field
      end

      def add_row(row)
        @rows << row
      end

      def flush
        headers = @fields.collect(&:name)
        csv_options = {
          :headers => headers,
          :write_headers => true
        }
        csv =
          if @options[:file]
            ::CSV.open(@options[:file], 'wb', csv_options)
          elsif @options[:string]
            @data = ""
            ::CSV.new(@data, csv_options)
          end
        @rows.each do |row|
          csv << row.values_at(*headers)
        end
        csv.close
      end

      def data
        if @options[:string]
          @data
        end
      end
    end
  end
end
