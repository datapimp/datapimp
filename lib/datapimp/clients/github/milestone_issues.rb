module Datapimp::Clients
  module Github
    class MilestoneIssues < RepositoryIssues

      def params
        p = @params

        if options[:milestone] && milestone.respond_to?(:number)
          p[:milestone_number] = milestone.number
        end

        p
      end
    end
  end
end
