require "datapimp/filterable/results_wrapper"

module Datapimp
  module Filterable
    class Context
      attr_accessor :all, :scope, :user, :params, :results

      class_attribute :results_wrapper

      def initialize(scope, user, params)
        @all      = scope.dup
        @scope    = scope
        @params   = params.dup
        @user     = user

        build_scope
      end

      def execute
        wrap_results
      end

      def clone
        self.class.new(all, user, params)
      end

      def wrap_results
        wrapper = self.class.results_wrapper || ResultsWrapper
        @results = wrapper.new(self.scope)
      end

      def build_scope
        @scope ||= self.scope
      end
    end
  end
end
