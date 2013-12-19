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
        @last_modified = nil
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
        @results = wrapper.new(self, last_modified)
      end

      def last_modified
        @last_modified ||= self.scope.maximum(:updated_at)
      end

      def etag
        Digest::MD5.hexdigest(cache_key)
      end

      def user_id
        user.try(:id)
      end

      def cache_key
        base  = scope.scope_attributes.inject([scope.klass.to_s]) {|m,k| m << k.map(&:to_s).map(&:strip).join(':') }

        p = params.dup

        p.delete :controller
        p.delete :action
        p.delete :format

        parts = p.inject(base) do |m,k|
          m << k.map(&:to_s).map(&:strip).join(':')
        end

        key   = parts.sort.uniq.join('/')

        key = "#{ key }/#{ scope.maximum(:updated_at).to_i }/#{ scope.count }"
        key += "/#{user_id}" unless user_id.nil?

        key
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
