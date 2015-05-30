module Datapimp
  module Clients
    class Dropbox
      include Singleton

      def self.method_missing(meth, *args, &block)
        if client.respond_to?(meth)
          return client.send(meth, *args, &block)
        end

        super
      end

      def self.client(options={})
        require 'dropbox-api' unless defined?(::Dropbox::API)
        @client ||= begin
                      ::Dropbox::API::Config.app_key    = options.fetch(:dropbox_app_key) { Datapimp.config.dropbox_app_key }
                      ::Dropbox::API::Config.app_secret = options.fetch(:dropbox_app_secret) { Datapimp.config.dropbox_app_secret }
                      ::Dropbox::API::Config.mode       = options.fetch(:dropbox_app_type) { Datapimp.config.dropbox_app_type }
                      instance.with_options(options)
                    end
      end

      def sandboxed_app?
        entry = api.ls.first
        entry && entry.root == "app_folder"
      end

      def api
        @api ||= begin
                   token = options.fetch(:token) { Datapimp.config.dropbox_client_token }
                   secret = options.fetch(:secret) { Datapimp.config.dropbox_client_secret }
                   ::Dropbox::API::Client.new(token: token  , secret: secret)
                 end
      end

      def find(path)
        api.find(path)
      rescue ::Dropbox::API::Error::NotFound
        nil
      end

      def push_from(local_path, options={})
        path_prefix = options.fetch(:prefix)
        root        = options[:root]

        unless find(path_prefix)
          api.mkdir(path_prefix)
        end

        uploader = lambda do |node|
          next if node.to_s == ".DS_Store"

          if node.directory?
            Array(node.children).each(&uploader)
          elsif node.file?
            relative = node.relative_path_from(local_path)
            target = "#{path_prefix}/#{relative}"
            target = target.gsub(/^\//,'')
            api.upload(target, node.read)
          end
        end

        Pathname(local_path).children.each(&uploader)
      end

      def create_site_folder(folder, allow_overwrite=false)
        found = find(folder)

        unless (!found || (found && !allow_overwrite))
          api.mkdir("/#{folder}")
        end
      end

      def method_missing meth, *args, &block
        if api.respond_to?(meth)
          return api.send(meth, *args, &block)
        end

        super
      end

      def authorize(token, secret)
        @api = nil if @api
        options[:token] = token
        options[:secret] = secret
        self
      end

      def options
        @options ||= {}
      end

      def with_options(opts={})
        options.merge!(opts)
        self
      end

      def requires_setup?
        !(dropbox_app_key.length > 0 && dropbox_app_secret.length > 0)
      end

      def dropbox_app_key
        Datapimp.config.dropbox_app_key.to_s
      end

      def dropbox_app_secret
        Datapimp.config.dropbox_app_secret.to_s
      end

      def setup(options={})
        interactive_setup(options)
      end

      def request_token
        @request_token ||= begin
                           consumer = ::Dropbox::API::OAuth.consumer(:authorize)
                           consumer.get_request_token
                         end
      end

      def browser_authorization_url
        @browser_authorization_url ||= request_token.authorize_url
      end

      def consume_auth_client_code code=nil
        if code.nil?
          query  = browser_authorization_url.split('?').last
          params = CGI.parse(query)
          code  = params['oauth_token'].first
        end

        request_token.get_access_token(:oauth_verifier => code).tap do |access_token|
          Datapimp.config.set 'dropbox_client_token', access_token.token
          Datapimp.config.set 'dropbox_client_secret', access_token.secret
        end
      end

      def interactive_setup(options={})
        if requires_setup?
          if dropbox_app_key.length == 0
            if answer = options[:dropbox_app_key] || ask("What is the dropbox app key?", String)
              Datapimp.config.set("dropbox_app_key", answer)
            end
            if answer = options[:dropbox_app_secret] || ask("What is the dropbox app secret?", String)
              Datapimp.config.set("dropbox_app_secret", answer)
            end
          end
        end

        raise 'Missing dropbox application values' if requires_setup?

        ::Dropbox::API::Config.app_key    = Datapimp.config.dropbox_app_key
        ::Dropbox::API::Config.app_secret = Datapimp.config.dropbox_app_secret

        auth_url = browser_authorization_url
        puts "\nGo to this url and click 'Authorize' to get the token:"
        puts auth_url
        Launchy.open(auth_url)

        print "\nOnce you authorize the app on Dropbox, press enter... "
        STDIN.gets.chomp

        access_token = consume_auth_client_code()

        puts "\nAuthorization complete!:\n\n"
        puts "  Dropbox::API::Config.app_key    = '#{Datapimp.config.dropbox_app_key}'"
        puts "  Dropbox::API::Config.app_secret = '#{Datapimp.config.dropbox_app_secret}'"
        puts "  Dropbox::API::Config.mode = '#{Datapimp.config.dropbox_app_type}'"
        puts "  client = Dropbox::API::Client.new(:token  => '#{access_token.token}', :secret => '#{access_token.secret}')"
        puts "\n"
      end
    end
  end
end
