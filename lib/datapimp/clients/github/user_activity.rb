module Datapimp::Clients
  module Github
    class UserActivity < Request

      def org
        @org || Datapimp::Clients::Github.default_organization
      end

      def endpoint
        "users/#{user}/events"
      end

      def organization_repos
        all.select do |item|
          item.repo && item.repo.name.try(:match,org) rescue false
        end
      end

    end
  end
end
