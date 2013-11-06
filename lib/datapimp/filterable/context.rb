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
        @results || wrap_results
      end

      def reset
        @results = nil
        self
      end

      def anonymous?
        user.try(:id).nil?
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

      def find id
        self.scope.find(params[:id])
      end
    end
  end
end
