module Datapimp
  module Sync
    class CloudfrontDistribution
      include Datapimp::Logging

      attr_accessor :bucket

      def initialize(options={})
        @bucket = options.fetch(:bucket)
      end

      def cloudfront
        @cloudfront ||= Datapimp::Sync.amazon.cdn.distributions.detect do |dist|
          dist.comment == bucket
        end
      end

      def method_missing(meth, *args, &block)
        cloudfront.send(meth, *args, &block)
      end
    end
  end
end
