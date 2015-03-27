module Datapimp
  module Clients
    class Github
      include Singleton

      def self.method_missing(meth, *args, &block)
        if client.respond_to?(meth)
          return client.send(meth, *args, &block)
        end

        super
      end

      def self.client(options={})
        require 'octokit' unless defined?(::Oktokit)

        @client ||= begin
                      instance.with_options(options)
                    end
      end

      def options
        @options ||= {}
      end

      def with_options(opts={})
        options.merge!(opts)
        self
      end

      def api
        @api ||= begin
                   Octokit::Client.new(access_token: Datapimp.config.github_access_token)
                 end
      end

      def setup(options={})
        access_token = options[:github_access_token] || Datapimp.config.github_access_token

        unless access_token.to_s.length == 40
          puts "You should generate an access token to use with the Github client."
          puts "Access tokens allow you to revoke and/or limit access if needed."
          puts "To learn more about access tokens, and how to generate them, visit: https://help.github.com/articles/creating-an-access-token-for-command-line-use/"

          if respond_to?(:ask)
            access_token = ask("Enter a 40 character access token when you have one", String)
          end
        end

        unless access_token.to_s.length == 40
          puts "Can not proceed without a valid access token: error code #{ access_token.length }"
          return
        end

        Datapimp.config.set(:github_access_token, access_token)
      end
    end
  end
end
