module Ethel
  module Writers
    class Memory < Writer
      def initialize
        @field_names = []
        @data = []
      end

      def prepare(dataset)
        dataset.each_field do |field|
          @field_names << field.name
        end
      end

      def add_row(row)
        @data << row.select { |(k, v)| @field_names.include?(k) }
      end

      def data
        @data
      end
    end
  end
end
