module Datapimp
  module Filterable
    class CachedContext < Context
      def cache_key
        base  = scope.scope_attributes.inject([scope.klass.to_s]) {|m,k| m << k.map(&:to_s).map(&:strip).join(':') }
        parts = params.inject(base) {|m,k| m << k.map(&:to_s).map(&:strip).join(':') }
        key   = parts.sort.uniq.join('/')

        "#{ key }/#{ scope.maximum(:updated_at).to_i }/#{ scope.count }"
      end

      def execute
        Rails.cache.fetch(cache_key) do
          wrap_results
        end
      end
    end
  end
end
