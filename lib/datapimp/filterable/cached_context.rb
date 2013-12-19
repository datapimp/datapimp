module Datapimp
  module Filterable
    class CachedContext < Context
      def execute
        Rails.cache.fetch(cache_key) do
          wrap_results
        end
      end
    end
  end
end
