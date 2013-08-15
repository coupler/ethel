module Ethel
  module Adapters
    module CSV
      class Reader < ::Ethel::Reader
        include Common

        def initialize(options)
          if !options.has_key?(:string) && !options.has_key?(:file)
            raise "either the :file or :string option must be specified"
          end
          @options = options
        end

        def read(dataset)
          field_names = get_field_names(@options)
          field_names.each do |field_name|
            field = Field.new(field_name, :type => :string)
            dataset.add_field(field)
          end
          dataset
        end

        def each_row
          csv_options = @options[:csv_options] || {}
          read_csv(@options, csv_options.merge(:headers => true)) do |csv|
            csv.each do |row|
              yield row.to_hash
            end
          end
        end

        ::Ethel::Reader.register('csv', self)
      end
    end
  end
end
