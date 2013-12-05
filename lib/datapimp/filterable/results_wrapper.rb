module Datapimp
  module Filterable
    class ResultsWrapper
      attr_accessor :results, :last_modified, :scope

      def initialize results, last_modified=nil
        @results = results
        @scope = results && results.scope
        @last_modified = last_modified

        raise "Invalid Results Object" if scope.nil?
      end

      def method_missing meth, *args, &blk
        if scope.respond_to?(meth)
          return scope.send(meth,*args,&blk)
        end

        if results.respond_to?(meth)
          return results.send(meth,*args,&blk)
        end

        super
      end

      def empty?
        results_count == 0
      end

      def results_count
        scope.count == 0
      end

      def last_modified
        @last_modified || scope.maximum(:updated_at)
      end

      def as_json options={}
        scope.as_json(options)
      end
    end
  end
end
