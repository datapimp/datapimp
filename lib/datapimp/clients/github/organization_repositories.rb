module Datapimp::Clients
  module Github
    class OrganizationRepositories < Request
      def org
        @org
      end

      def all
        @all ||= self.result
      end

      def to_list
        all.map do |repository|
          repository.slice("id","name","html_url","description","ssh_url")
        end
      end

      def endpoint
        "orgs/#{ org }/repos"
      end
    end
  end
end
