module Datapimp::Sources
  class Pivotal < Datapimp::Sources::Base
    def initialize(args, options)
      @project_id = args.shift
      @story_id   = args.shift
      @options    = options.to_mash

      PivotalTracker::Client.token = Datapimp.config.pivotal_access_token
    end

    def all
      %w(user_activity project_activity project_stories).each_with_object({}) do |slice, memo|
        memo[slice] = send(slice)
      end
    end

    def to_s
      all
    end

    def user_activity
      @_user_activity ||= PivotalTracker::Activity.all(nil, limit_params).map(&:jsonify)
    end

    def project_activity
      project.activities.all(limit_params).map(&:jsonify)
    end

    def project_stories
      stories = project.stories.all(limit_params)

      # add notes for each story and convert the objects to hashes
      stories.map do |story|
        story_hash = jsonify(story)
        story_hash[:notes] = story.notes.all.map(&:jsonify)
        story_hash
      end
    end

    def project_story_notes
      notes = project.stories.find(@story_id).notes.all(limit_params)
      notes.map(&:jsonify)
    end

    private

    def project
      @_project ||= PivotalTracker::Project.find(@project_id)
    end

    def limit_params
      @_limit_params ||= begin
        h = {}
        h[:limit]   = @options.limit if @options.limit
        h[:offset]  = @options.offset if @options.offset
        h
      end
    end
  end
end
