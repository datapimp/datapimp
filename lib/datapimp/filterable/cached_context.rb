module Datapimp
  module Filterable
    class CachedContext < Context
      def etag
        Rails.cache.fetch("etags:#{cache_key}") do
          Digest::MD5.hexdigest(wrap_results.as_json.to_json)
        end
      end

      def execute
        Rails.cache.fetch(cache_key) do
          wrap_results
        end
      end
    end
  end
end
