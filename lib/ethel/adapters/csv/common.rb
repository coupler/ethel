module Ethel
  module Adapters
    module CSV
      module Common
        def read_csv(options, csv_options = options[:csv_options] || {}, &block)
          if options[:string]
            csv = ::CSV.new(options[:string], csv_options)
            if block
              block.call(csv)
            else
              csv
            end
          elsif options[:file]
            ::CSV.open(options[:file], 'rb', csv_options, &block)
          end
        end

        def write_csv(options, csv_options = options[:csv_options] || {}, &block)
          if options[:string]
            ::CSV.generate(csv_options, &block)
          elsif options[:file]
            ::CSV.open(options[:file], 'wb', csv_options, &block)
          end
        end

        def get_field_names(options, csv_options = options[:csv_options] || {})
          result = nil
          opts = csv_options.merge(:headers => false)
          if options[:string]
            result = ::CSV.parse_line(options[:string], opts)
          elsif options[:file]
            ::CSV.open(options[:file], opts) do |csv|
              result = csv.shift
            end
          end
          result
        end
      end
    end
  end
end
