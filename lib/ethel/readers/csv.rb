module Ethel
  module Readers
    class CSV < Reader
      def initialize(options = {})
        @options = options
      end

      def read(dataset)
        field_names = nil
        if @options[:string]
          field_names = ::CSV.parse_line(@options[:string])
        elsif @options[:file]
          ::CSV.open(@options[:file]) do |csv|
            field_names = csv.shift
          end
        end

        field_names.each do |field_name|
          field = Field.new(field_name, :type => :string)
          dataset.add_field(field)
        end
        dataset
      end

      def each_row
        csv =
          if @options[:string]
            ::CSV.new(@options[:string], :headers => true)
          elsif @options[:file]
            ::CSV.open(@options[:file], :headers => true)
          end
        begin
          csv.each do |row|
            yield row.to_hash
          end
        ensure
          csv.close
        end
      end
    end
  end
end
