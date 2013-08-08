module Ethel
  module Register
    module ClassMethods
      def register(name, klass)
        @subclasses ||= {}
        @subclasses[name] = klass
      end

      def [](name)
        @subclasses ? @subclasses[name] : nil
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
