module Datapimp
  module Filterable
    class Context
      attr_accessor :scope, :user, :params, :results

      def initialize(scope, user, params)
        @scope    = scope
        @params   = params.dup
        @user     = user
      end

      def execute
        build_scope
        @results = self.scope
      end

      def build_scope
      end
    end
  end
end
