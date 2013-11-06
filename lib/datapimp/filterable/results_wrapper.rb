module Datapimp
  module Filterable
    class ResultsWrapper
      attr_accessor :results, :last_modified

      def initialize results, last_modified=nil
        @results = results
        @last_modified = last_modified
      end

      def method_missing meth, *args, &blk
        if results.respond_to?(meth)
          return results.send(meth,*args,&blk)
        end

        super
      end

      def find id
        case
        when results.respond_to?(:where)
          results.find(id)
        when results.respond_to?(:detect)
          results.detect do |hash|
            hash.fetch("id") == id
          end
        end
      end

      def last_modified
        @last_modified || self.scope.maximum(:updated_at)
      end

      def as_json options={}
        results.as_json(options)
      end
    end
  end
end
