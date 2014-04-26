# We have to know if we're being created from a cache hit / cache miss.
# We need to store with only data, not object s

module Datapimp
  module Filterable
    class ResultsWrapper

      def self.wrap(object, last_modified=nil)
        if object.is_a?(Hash)
          object = Hashie::Mash.new(object)
        else
          fresh = true
        end

        new(fresh) do
          begin
            self.records ||= object.serialize_results.as_json
          rescue => e
            puts "Error serializing filter context: #{ $! }"
            Rails.logger.error "ERROR Serializing: #{ object.class } #{ $! }"
            Rails.logger.error e.backtrace
            raise(e) unless $suppress_datapimp_serialization_errors
          end

          self.last_modified ||= last_modified || object.last_modified
          self.etag ||= object.etag
          self.cache_key ||= object.cache_key
          self.params ||= object.params
        end
      end

      attr_accessor :cache_key, :last_modified, :etag, :records, :fresh, :params, :message

      def initialize(fresh, &block)
        instance_eval(&block) if block_given?
      end

      def to_a
        Array(@records)
      end

      def serialize_results
        to_a
      end

      def empty?
        to_a.empty?
      end

      def fresh?
        !!@fresh
      end

      def mash_objects
        @mash_objects ||= to_a.map {|obj| Hashie::Mash.new(obj) }
      end

      def dump
        {
          cache_key: cache_key,
          etag: etag,
          fresh: false,
          last_modified: last_modified,
          records: records
        }
      end

    end
  end
end
