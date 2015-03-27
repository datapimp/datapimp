require 'launchy'

module Datapimp
  module Cli
    def self.load_commands(from_path=nil)
      from_path ||= Datapimp.lib.join("datapimp","cli")
      Dir[from_path.join("**/*.rb")].each {|f| require(f) }
    end

    def self.accepts_keys_for(c, *services)
      services.map!(&:to_sym)

      if services.include?(:dropbox)
        c.option "--dropbox-app-key KEY", String, "The dropbox app key"
        c.option "--dropbox-app-secret SECRET", String, "The dropbox app secret"
        c.option "--dropbox-app-sandbox", "The dropbox app is a sandbox app"
        c.option "--dropbox-client-token TOKEN", String, "The dropbox client token"
        c.option "--dropbox-client-secret SECRET", String, "The dropbox client secret"
        c.option "--dropbox-path-prefix PATH", String, "The path prefix for this folder (for sandboxed apps)"
      end

      if services.include?(:google)
        c.option "--google-client-id KEY", String, "The google client id"
        c.option "--google-client-secret KEY", String, "The google client secret"
        c.option "--google-refresh-token", String, "The google refresh token"
        c.option "--google-access-token KEY", String, "The google access token"
      end

      if services.include?(:dnsimple)
        c.option "--dnsimple-api-token", String, "The DNSimple API Token"
        c.option "--dnsimple-username", String, "The DNSimple Username"
      end

      if services.include?(:github)
        c.option "--github-username", String, "The Github Username"
        c.option "--github-organization", String, "The Github Organization"
        c.option "--github-access-token", String, "The Github Personal Access Token"
        c.option "--github-app-key", String, "The Github App Key"
        c.option "--github-app-secret", String, "The Github App Secret"
      end

      if services.include?(:amazon) || services.include?(:aws)
        c.option '--aws-secret-access-key', String, 'AWS Secret Access Key'
        c.option '--aws-access-key-id', String, 'AWS Access Key ID'
      end

    end
  end
end
