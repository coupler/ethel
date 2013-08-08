module Ethel
  module Adapters
    module CSV
      class Reader < ::Ethel::Reader
        def initialize(options)
          if !options.has_key?(:string) && !options.has_key?(:file)
            raise "either the :file or :string option must be specified"
          end
          @options = options
          @csv_options = options[:csv_options] || {}
        end

        def read(dataset)
          field_names = nil
          if @options[:string]
            field_names = ::CSV.parse_line(@options[:string], @csv_options.merge(:headers => false))
          elsif @options[:file]
            ::CSV.open(@options[:file], @csv_options.merge(:headers => false)) do |csv|
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
              ::CSV.new(@options[:string], @csv_options.merge(:headers => true))
            elsif @options[:file]
              ::CSV.open(@options[:file], @csv_options.merge(:headers => true))
            end
          begin
            csv.each do |row|
              yield row.to_hash
            end
          ensure
            csv.close
          end
        end

        ::Ethel::Reader.register('csv', self)
      end
    end
  end
end
