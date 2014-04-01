require 'set'

module Datapimp
  module Filterable
    class Context

      include ActiveSupport::DescendantsTracker

      def self.all
        descendants
      end

      def self.cached_contexts
        descendants.select {|klass| klass.cached? }
      end

      def self.caching_report
        cached_contexts.inject({}) do |memo,klass|
          memo[klass.name] = klass.cached? && klass.cache_stats_report
          memo
        end
      end


      # By default, the Filterable::Context is
      # anonymous.  Which means the output of the query
      # is not presented differently for each consumer.
      #
      # An anonymous filter context does not build
      # the identity of the user into the cache key. This
      # means bob will see the same results as kathy.
      class_attribute :_anonymous

      self._anonymous = true

      # The opposite of this, for records whose output
      # may be different based on who is seeing them, you can
      # build the user id into the cache key. This will prevent
      # bob from seeing cached output designed for kathy.
      def self.not_anonymous
        self._anonymous = false
      end

      def self.anonymous setting=true
        self._anonymous = !!setting
      end

      def self.anonymous?
        !!(self._anonymous)
      end

      # By default, we allow filtering by all attributes on
      # the model.  This is most certainly not secure and you should
      # customize it.  To do it on a white list of attributes, is one way
      class_attribute :filters

      self.filters = Set.new()

      def self.filterable_by *keys
        filters << keys.map(&:to_sym)
      end

      attr_accessor :scope, :user, :params, :results, :controller, :root

      # The whole point of the Filter Context class, though, is to
      # provide you with a place to declare your logic for querying
      # API resources.  The FilterContext gives you access to who is
      # querying what, using what parameters, so you can customize how
      # you see fit.
      def initialize(scope, user, params, &block)
        @scope    = scope
        @params   = params.dup
        @user     = user

        instance_eval(block) if block_given?

        build
      end

      def root
        @root || false
      end

      def paginated?
        params.has_key?(:page)
      end

      def execute controller=nil
        @controller = controller
        cached? ? execute_with_caching : execute_without_caching
      end

      def find id
        self.scope.find(id)
      end

      def reset
        @results = nil
        @last_modified = nil
        self
      end

      def last_modified
        @last_modified ||= self.scope.maximum(:updated_at)
      end

      def build
        build_scope
      end

      def find_single?
        params.has_key?(:id)
      end

      def user_id
        user.try(:id)
      end

      def anonymous?
        self.class.anonymous? || user_id.nil?
      end

      def include_user_id_in_cache_key?
        !anonymous?
      end

      def build_scope
        @scope ||= self.scope
      end

      # TODO
      # The default implementation of build scope
      # could do a basic equality check for all of the parameters
      # whose keys match column names on the underlying activerecord
      def build_scope_from_columns
        self.scope
      end

      class_attribute :_cached

      def self.cached
        include Datapimp::Filterable::CacheStatistics
        self._cached = true
      end

      def self.enable_caching
        cached
      end

      def self.disable_caching
        self._cached = false
      end

      def self.cached?
        !!(_cached)
      end

      def cached?
        self.class.cached?
      end

      def etag
        # TODO
        # Incorporating the user is good when generating the ETag.  This prevents
        # serving cached data intended for one user, to another.  We need to measure
        # the performance of cache hit / cache miss ratio on the server though.
        # Digest::MD5.hexdigest(anonymous? ? "#{cache_key}/#{user_id}" : cache_key)
        Digest::MD5.hexdigest(cache_key)
      end

      def cache_key
        base  = scope.scope_attributes.inject([scope.klass.to_s]) {|m,k| m << k.map(&:to_s).map(&:strip).join(':') }

        parts = params.except(:format,:controller,:action)
          .inject(base) { |m,k| m << k.map(&:to_s).map(&:strip).join(':') }
          .sort
          .uniq

        parts << scope.maximum(:updated_at).to_i << scope.count

        # See the command above in the etag method. I need to
        # measure the cache hit / miss ratio when including this
        # in the cache key on the server, instead of just the etag.
        parts << user_id if include_user_id_in_cache_key?

        parts.join('/')
      end

      def wrap object, last_modified=nil
        ResultsWrapper.wrap(object, last_modified)
      end

      def serialize_results
        ActiveModel::Serializer.build_json(controller, scope, root: root, scope: user )
      end

      def controller
        @controller || OpenStruct.new(default_serializer_options:{}, url_options: {}, scope: user, _serializer_scope: :current_user)
      end

      def execute_with_caching
        result = Rails.cache.read(cache_key)

        if result
          record_cache_hit(cache_key)
          return wrap(result)
        end

        @results = wrap_results

        Rails.cache.write(cache_key, @results.dump)

        record_cache_miss(cache_key)

        @results
      end

      def execute_without_caching
        @results || wrap_results
      end

      def wrap_results
        wrap(self, last_modified)
      end

    end
  end
end

unless defined?(ApplicationFilterContext)
  ApplicationFilterContext = Class.new(Datapimp::Filterable::Context)
end
