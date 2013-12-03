module Datapimp::Clients
  module Github
    class OrganizationActivity < Request
      def endpoint
        "users/#{ user }/events/orgs/#{ org }"
      end
    end
  end
end
