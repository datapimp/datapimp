require 'uri'

module Datapimp
  module Aws
    class SignedCookie
      attr_accessor :options,
                    :expiry,
                    :url

      def initialize(options={})
        @options = options
        @expiry  = options.fetch(:expiry) { 24.hours.from_now }
        @url     = options.fetch(:url)
        @path    = options.fetch(:path) { '/' }
        @domain  = options.fetch(:domain) { URI.parse(@url).host }
      end

      def set(cookies)
        cookie_data.each do |k,v|
          cookies[k] = {value: v, domain: domain, path: path}
        end
      end

      def cookie_data
        raw_policy = policy(url, expiry)
        {
          'CloudFront-Policy' => safe_base64(raw_policy),
          'CloudFront-Signature' => sign(raw_policy),
          'CloudFront-Key-Pair-Id' => Datapimp.config.aws_cloudfront_keypair_id
        }
      end

      private

      def policy(url, expiry)
        {
           "Statement"=> [
              {
                 "Resource" => url,
                 "Condition"=>{
                    "DateLessThan" =>{"AWS:EpochTime"=> expiry.utc.to_i}
                 }
              }
           ]
        }.to_json.gsub(/\s+/,'')
      end

      def safe_base64(data)
        Base64.strict_encode64(data).tr('+=/', '-_~')
      end

      def sign(data)
        digest = OpenSSL::Digest::SHA1.new
        key    = OpenSSL::PKey::RSA.new(Datapimp.config.aws_cloudfront_private_key)
        result = key.sign digest, data
        safe_base64(result)
      end
    end
  end
end
