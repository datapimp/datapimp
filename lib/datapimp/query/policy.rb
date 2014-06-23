module Datapimp
  class Query
    class Policy
      include Singleton

      def self.method_missing meth, *args, &block
        if instance.respond_to?(meth)
          return instance.send(meth, *args, &block)
        end

        super
      end

    end
  end
end
