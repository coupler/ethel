module Ethel
  class Field
    attr_reader :name, :type

    def initialize(name, options)
      @name = name
      @type = options[:type]
    end
  end
end
