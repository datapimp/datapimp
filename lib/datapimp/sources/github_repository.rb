module Datapimp::Sources
  class GithubRepository < Datapimp::Sources::Base
    attr_reader :options, :repository

    def initialize(repository, options)
      @repository = repository
      @options    = options.to_mash
    end

    def all
      %w(issues milestones commits releases).reduce({}) do |memo, slice|
        memo[slice] = send(slice)
        memo
      end
    end

    def to_s
      all
    end

    def issues
      issues = client.issues(repository, filter: "all")
      issues.map! do |issue|
        %w(comments events labels).each do |rel|
          issue[rel] = issue.rels[rel].get.data if relations.include?(rel)
        end
        issue
      end
      serve_output(issues)
    end

    def milestones
      milestones = client.milestones(repository)
      serve_output(milestones)
    end

    def releases
      releases = client.releases(repository)
      serve_output(releases)
    end

    def commits
      commits = client.commits(repository)
      serve_output(commits)
    end

    private

    def client
      @_client ||= Datapimp::Sync.github.api
    end

    def relations
      @_relations ||= Array(@options.relations)
    end

    def serve_output(output)
      if output.is_a?(Array)
        output.map! do |o|
          o.respond_to?(:to_attrs) ? o.send(:to_attrs) : o
        end
      end

      output
    end
  end
end
