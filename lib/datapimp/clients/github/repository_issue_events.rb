module Datapimp::Clients
  module Github
    class RepositoryIssueEvents < Request
      def org
        @org || Datapimp::Clients::Github.default_organization
      end

      def endpoint
        "repos/#{ org }/#{ repo }/issues/events"
      end
    end
  end
end
