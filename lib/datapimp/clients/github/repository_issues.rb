module Datapimp::Clients
  module Github
    class RepositoryIssues < Request
      def org
        @org || Datapimp::Clients::Github.default_organization
      end

      def endpoint
        "repos/#{ org }/#{ repo }/issues"
      end

    end
  end
end
