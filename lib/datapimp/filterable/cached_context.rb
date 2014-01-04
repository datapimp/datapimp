module Datapimp
  module Filterable
    class CachedContext < Context

      cached

      def self.deprecation_message
        ::Rails.logger.warn "The CachedContext class has been deprecated.  Just use cached = true property on the context class"
      end

      def self.inherited base
        Rails.logger.warn "#{ base } is using CachedContext"
        deprecation_message
      end

      def initialize *args
        self.class.deprecation_message
        super
      end

    end
  end
end
