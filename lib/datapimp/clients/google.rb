module Datapimp
  module Clients
    class Google
      include Singleton

      def self.method_missing(meth, *args, &block)
        if client.respond_to?(meth)
          return client.send(meth, *args, &block)
        end

        super
      end

      def self.client(options={})
        unless defined?(::GoogleDrive)
          require 'google_drive'
          require 'google/api_client'
          require 'google_drive/session'
        end

        @client ||= begin
                      instance.with_options(options)
                    end
      end

      def refreshable?
        has_application_keys? && has_refresh_token?
      end

      # Runs through an interactive session where we get the
      # necessary tokens needed to integrate with google drive.
      def setup(options={})
        get_application_keys unless has_application_keys?

        if options[:client_id]
          Datapimp.config.set "google_client_id", options[:client_id]
        end

        if options[:client_secret]
          Datapimp.config.set "google_client_secret", options[:client_secret]
        end

        if has_refresh_token?
          refresh_access_token!
        elsif respond_to?(:ask)
          Launchy.open(auth_client.authorization_uri)
          say("\n1. Open this page:\n%s\n\n" % auth_client.authorization_uri)
          auth_client.code = ask("2. Enter the authorization code shown in the page: ", String)
          auth_client.fetch_access_token!
          Datapimp.config.set "google_refresh_token", auth_client.refresh_token
          Datapimp.config.set "google_access_token", auth_client.access_token
        end
      end

      def session
        api
      end

      def api
        @api ||= begin
                   refresh_access_token!
                   GoogleDrive.login_with_oauth(Datapimp.config.google_access_token)
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

      def has_application_keys?
        (Datapimp.config.google_client_id.to_s.length > 0 && Datapimp.config.google_client_secret.to_s.length > 0)
      end

      def get_application_keys
        unless Datapimp.config.google_client_id.to_s.length > 0
          google_client_id = ask("What is the Google Client ID?", String)
          Datapimp.config.set "google_client_id", google_client_id
        end

        unless Datapimp.config.google_client_secret.to_s.length > 0
          google_client_secret = ask("What is the Google Client Secret?", String)
          Datapimp.config.set "google_client_secret", google_client_secret
        end
      end

      def auth_client
        return @auth_client if @auth_client

        client = ::Google::APIClient.new(
            :application_name => "google_drive Ruby library",
            :application_version => "0.3.11"
        )

        client_id = "452925651630-egr1f18o96acjjvphpbbd1qlsevkho1d.apps.googleusercontent.com"
        client_secret = "1U3-Krii5x1oLPrwD5zgn-ry"

        @auth_client = auth = client.authorization
        auth.client_id = client_id #Datapimp.config.google_client_id
        auth.client_secret = client_secret #Datapimp.config.google_client_secret
        auth.scope =
            "https://www.googleapis.com/auth/drive " +
            "https://spreadsheets.google.com/feeds/ " +
            "https://docs.google.com/feeds/ " +
            "https://docs.googleusercontent.com/"

        auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"

        auth
      end

      def refresh_token
        Datapimp.config.google_refresh_token.to_s
      end

      def has_refresh_token?
        refresh_token.length > 0
      end

      def refresh_access_token!
        if has_refresh_token?
          auth_client.refresh_token = refresh_token
          auth_client.fetch_access_token!
          Datapimp.config.set "google_access_token", auth_client.access_token
        end
      end

    end
  end
end
