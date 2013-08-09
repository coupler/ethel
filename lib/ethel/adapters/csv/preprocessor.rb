module Ethel
  module Adapters
    module CSV
      class MissingFieldNameError < Error
        CHOICES = [{:rename => {:name => :string}}, :drop]

        def initialize(colnum)
          super('missing field name', true, {:colnum => colnum})
        end

        protected

        def choices
          CHOICES
        end
      end

      class Preprocessor < ::Ethel::Preprocessor
        protected

        def validate
          # Check headers
          @field_names ||= get_field_names
          @field_names.each_with_index do |field_name, i|
            if field_name.nil?
              error = MissingFieldNameError.new(i)
              @errors << error
            end
          end
        end

        private

        def get_field_names
          result = nil
          opts = csv_options.merge(:headers => false)
          if @options[:string]
            result = ::CSV.parse_line(@options[:string], opts)
          elsif @options[:file]
            ::CSV.open(@options[:file], opts) do |csv|
              result = csv.shift
            end
          end
          result
        end

        def csv_options
          @options[:csv_options] || {}
        end
      end
    end
  end
end
