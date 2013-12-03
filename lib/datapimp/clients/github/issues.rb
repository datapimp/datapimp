module Datapimp::Clients
  module Github
    class Issues < Request
      def params
        @params.merge(sort:"updated")
      end

      def endpoint
        "orgs/#{ org }/issues"
      end
    end
  end
end
