require 'pivotal-tracker'
require 'datapimp/sync/base'

module Datapimp::Sync
  class Pivotal < Base
    attr_reader :options

    def initialize(options)
      super(options)
      PivotalTracker::Client.token = Datapimp.config.pivotal_access_token
    end

    def user_activity
      @_user_activity ||= PivotalTracker::Activity.all(nil, limit_params)

      serve_output(@_user_activity)
    end

    def project_activity(project_id)
      @project_id = project_id

      activity = project.activities.all(limit_params)

      serve_output(activity)
    end

    def project_stories(project_id)
      @project_id = project_id

      stories = project.stories.all(limit_params)

      # add notes for each story and convert the objects to hashes
      list = stories.map do |story|
        story_hash = object_to_hash(story)
        story_hash[:notes] = story.notes.all.map do |note|
          object_to_hash(note)
        end
        story_hash
      end

      serve_output(list)
    end

    def project_story_notes(project_id, story_id)
      @project_id = project_id

      notes = project.stories.find(story_id).notes.all(limit_params)
      list  = notes.map {|n| object_to_hash(n) }

      serve_output(list)
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
