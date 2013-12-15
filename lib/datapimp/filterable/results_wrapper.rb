module Datapimp
  module Filterable
    class ResultsWrapper
      attr_accessor :filter_context, :last_modified, :scope

      def initialize filter_context, last_modified=nil
        @filter_context = filter_context
        @scope = filter_context && filter_context.scope
        @last_modified = last_modified

        raise "Invalid filter context Object" if scope.nil?
      end

      def method_missing meth, *args, &blk
        if scope.respond_to?(meth)
          return scope.send(meth,*args,&blk)
        end

        if filter_context.respond_to?(meth)
          return filter_context.send(meth,*args,&blk)
        end

        super
      end

      if defined?(ActiveModel::Serializer)
        def active_model_serializer
          scope.klass.active_model_serializer
        end
      end

      def params
        filter_context.params
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
