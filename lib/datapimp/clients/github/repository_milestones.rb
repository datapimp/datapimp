module Datapimp::Clients
  module Github
    class RepositoryMilestones < Request
      def org
        @org || Datapimp::Clients::Github.default_organization
      end

      def endpoint
        "repos/#{ org }/#{ repo }/milestones"
      end
    end
  end
end
