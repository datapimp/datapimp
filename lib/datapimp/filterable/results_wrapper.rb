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

      def empty?
        results_count == 0
      end

      def results_count
        results.count == 0
      end

      def last_modified
        @last_modified || results.scope.maximum(:updated_at)
      end

      def as_json options={}
        results.as_json(options)
      end
    end
  end
end
