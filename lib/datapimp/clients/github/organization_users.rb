module Datapimp::Clients
  module Github
    class OrganizationUsers < Request
      def org
        @org || Datapimp::Clients::Github.default_organization
      end

      def endpoint
        options[:endpoint] || "orgs/#{ org }/members"
      end

      def self.logins
        new(user:"mantrabot").all.map(&:login)
      end
    end
  end
end
