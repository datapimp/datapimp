module Datapimp
  module Clients
    module GithubIntegrated
      extend ActiveSupport::Concern

      def github_token
        read_attribute(:github_token) || @github_token
      end

      def github_client
        @github_client ||= Clients::Github::Client.new(user: self)
      end
    end
  end
end
