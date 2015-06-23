require 'datapimp/sync/base'

module Datapimp::Sync
  class Github < Base
    attr_reader :repository

    def initialize(repository, options)
      @repository = repository
      super(options)
    end

    def sync_issues
      issues = client.issues(repository, filter: "all")
      issues.map! do |issue|
        %w(comments events labels).each do |rel|
          issue[rel] = issue.rels[rel].get.data if relations.include?(rel)
        end
        issue
      end
      serve_output(issues)
    end

    def sync_issue_comments(issue_id)
      comments = client.issue_comments(repository, issue_id)
      serve_output(comments)
    end

    private

    def client
      @_client ||= Datapimp::Sync.github.api
    end

    def relations
      @_relations ||= @options.relations.to_a
    end
  end
end
