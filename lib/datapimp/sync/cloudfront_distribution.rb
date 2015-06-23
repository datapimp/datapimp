module Datapimp
  module Sync
    class CloudfrontDistribution
      include Datapimp::Logging

      attr_accessor :bucket

      def self.create(options={})
        options = options.to_mash

        bucket = Datapimp::Sync::S3Bucket.new(remote: options.bucket)

        cdn_options = {
          enabled: true,
          custom_origin: {
            'DNSName'=> bucket.website_hostname,
            'OriginProtocolPolicy'=>'http-only'
          },
          comment: options.bucket,
          caller_reference: Time.now.to_i.to_s,
          cname: Array(options.domains),
          default_root_object: 'index.html'
        }

        distributions = Datapimp::Sync.amazon.cdn.distributions

        distribution_id = distributions.find {|d| d.comment == options.bucket }.try(:id)

        if !distribution_id
          distribution = Datapimp::Sync.amazon.cdn.distributions.create(cdn_options)
        elsif distribution_id
          distribution = distributions.get(distribution_id)
          distribution.etag = distribution.etag
          distribution.cname = Array(options.domains)
          distribution.save
        end

        if distribution
          new(bucket: options.bucket)
        end
      end

      def initialize(options={})
        @bucket = options.fetch(:bucket)
      end

      def cloudfront
        @cloudfront ||= Datapimp::Sync.amazon.cdn.distributions.detect do |dist|
          dist.comment == bucket
        end
      end

      def method_missing(meth, *args, &block)
        cloudfront && cloudfront.send(meth, *args, &block)
      end
    end
  end
end
