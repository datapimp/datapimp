module Datapimp
  module Clients
    module Github
      mattr_accessor :default_github_token, :default_organization

      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :Authentication
        autoload :Client
        autoload :Request
        autoload :RequestWrapper
      end

      autoload :IssueLabels
      autoload :Issues
      autoload :MilestoneIssues
      autoload :OrganizationActivity
      autoload :OrganizationRepositories
      autoload :OrganizationUsers
      autoload :RepositoryEvents
      autoload :RepositoryIssues
      autoload :RepositoryLabels
      autoload :RepositoryMilestones
      autoload :SingleRepository
      autoload :UserActivity
      autoload :UserInfo

    end
  end
end
