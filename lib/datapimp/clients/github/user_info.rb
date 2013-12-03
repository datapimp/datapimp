module Datapimp::Clients
  module Github
    class UserInfo < Request
      def endpoint
        "users/#{ user }"
      end
    end
  end
end
