module Ethel
  module Sources
    class CSV < Source
      def initialize(options = {})
        if options[:string]
          @data = ::CSV.parse(options[:string], :headers => true)
        elsif options[:file]
          @data = ::CSV.read(options[:file], :headers => true)
        end
      end

      def field_names
        @data.headers
      end

      def each
        @data.each do |row|
          yield row.to_hash
        end
      end
    end
  end
end
