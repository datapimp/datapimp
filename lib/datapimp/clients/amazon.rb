module Datapimp
  module Clients
    class Amazon
      include Singleton

      require 'fog/aws'

      def aws_access_key_id
        options[:aws_access_key_id] || options[:access_key_id] || Datapimp.config.aws_access_key_id
      end

      def aws_secret_access_key
        options[:aws_secret_access_key] || options[:secret_access_key] || Datapimp.config.aws_secret_access_key
      end

      def storage
        return @storage if @storage

        # Silence fog warnings
        Fog::Logger.define_singleton_method(:warning) do |*args|
          nil
        end

        @storage = Fog::Storage.new({
          provider: 'AWS',
          aws_access_key_id: aws_access_key_id,
          aws_secret_access_key: aws_secret_access_key,
          path_style: true
        })


        @storage
      end

      def cdn
        @cdn ||= Fog::CDN.new({
          provider: 'AWS',
          aws_access_key_id: aws_access_key_id,
          aws_secret_access_key: aws_secret_access_key
        })
      end

      def s3_bucket_website_url
        if s3_bucket.is_a?(Fog::Storage::AWS::Directory)
          website_url_for(s3_bucket)
        end
      end

      def site_description
        options[:description] || options[:site_name] || s3_bucket.key
      end

      # the domain, and the domain with www
      def site_domain_aliases
        options[:aliases]
      end

      def s3_bucket
        if bucket_name = options[:bucket_name] || Datapimp.config.get("bucket_name")
          if bucket = find_bucket_by_name(bucket_name)
            return bucket
          else
            "There is no bucket named: #{ bucket_name }. You can create one by running 'datapimp setup amazon --create-bucket=BUCKET_NAME"
          end
        else
          raise 'Could not determine bucketname for Datapimp.amazon.s3_bucket'
        end
      end

      def create_cdn_for(website_url, comment, aliases)
        aliases = aliases.join(",") if aliases.is_a?(Array)

        existing = cdn.distributions.find do |distribution|
          distribution.comment == comment
        end

        return existing if existing

        cdn.distributions.create(cdn_options(website_url: website_url, comment: comment, aliases: aliases))
      end

      def cdn_options(o={})
        {
          enabled: true,
          custom_origin: {
            'DNSName'=> o.fetch(:website_url) { s3_bucket_website_url },
            'OriginProtocolPolicy'=>'http-only'
          },
          comment: o.fetch(:comment) { site_description },
          caller_reference: Time.now.to_i.to_s,
          cname: o.fetch(:aliases) { site_domain_aliases },
          default_root_object: 'index.html'
        }
      end

      def self.client(options={})
        @client ||= begin
                      instance.with_options(options)
                    end
      end


      def self.method_missing(meth, *args, &block)
        if client.respond_to?(meth)
          return client.send(meth, *args, &block)
        end

        super
      end

      def website_host_for(bucket_or_bucket_name)
        URI.parse(website_url_for(bucket_or_bucket_name)).host
      end

      def website_url_for(bucket_or_bucket_name)
        bucket = bucket_or_bucket_name

        if bucket_or_bucket_name.is_a?(String)
          bucket = storage.directories.get(bucket_or_bucket_name)
        end

        if bucket
          "http://#{bucket.key}.s3-website-#{ bucket.location }.amazonaws.com"
        end
      end

      def find_or_create_bucket(bucket_name)
        find_bucket_by_name(bucket_name) || create_bucket(bucket_name)
      end

      def find_bucket_by_name(bucket_name)
        storage.directories.get(bucket_name) rescue nil
      end

      def create_bucket(bucket_name)
        storage.directories.create(key: bucket_name, public: true).tap do |bucket|
          storage.put_bucket_website(bucket_name, 'index.html', key: 'error.html')
          #storage.put_bucket_cors(bucket_name, {"AllowedOrigin"=>"*","AllowedMethod"=>"GET","AllowedHeader"=>"Authorization"})
        end
      end

      def create_redirect_bucket(bucket_name, redirect_to_bucket_name)
        create_bucket(redirect_to_bucket_name) unless find_bucket_by_name(redirect_to_bucket_name)
        create_bucket(bucket_name)
      end

      def with_options(opts={})
        options.merge!(opts)
        self
      end

      def options
        @options ||= {}
      end

      def has_application_keys?
        (Datapimp.config.aws_access_key_id.to_s.length > 0 && Datapimp.config.aws_secret_access_key.to_s.length > 0)
      end

      def interactive_setup(options={})
        secret_key    = Datapimp.config.aws_secret_access_key.to_s
        access_key_id  = Datapimp.config.aws_access_key_id.to_s

        secret_key = ask("What is the AWS Secret Access Key?") unless secret_key.length > 8
        access_key_id = ask("What is the AWS Access Key ID?") unless access_key_id.length > 8

        Datapimp.config.set(:aws_access_key_id, access_key_id) if access_key_id.length > 8
        Datapimp.config.set(:aws_secret_access_key, secret_key) if secret_key.length > 8
      end
    end
  end
end
