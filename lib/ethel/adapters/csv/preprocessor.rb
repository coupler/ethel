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
        include Common

        protected

        def validate
          # Check headers
          @field_names ||= get_field_names(@options)
          @field_names.each_with_index do |field_name, i|
            if field_name.nil?
              error = MissingFieldNameError.new(i)
              @errors << error
            end
          end
        end

        def process(process_options)
          cols = (0...@field_names.length).to_a
          each_error do |error|
            case error
            when MissingFieldNameError
              name, args = error.choice
              colnum = error.info[:colnum]

              case name
              when :rename
                @field_names[colnum] = args[:name]
              when :drop
                cols.delete_at(colnum)
              end
            end
          end

          write_csv(process_options) do |out_csv|
            out_csv << @field_names.values_at(*cols)

            read_csv(@options) do |in_csv|
              in_csv.shift
              in_csv.each do |row|
                out_csv << row.values_at(*cols)
              end
            end
          end
        end

        Ethel::Preprocessor.register('csv', self)
      end
    end
  end
end
