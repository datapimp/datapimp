require 'pivotal-tracker'

module Datapimp::Sync
  class Pivotal
    attr_reader :options

    def initialize(options)
      @options = options
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

    def object_to_hash(obj)
      if obj.is_a?(Array)
        obj.map {|o| object_to_hash(o) }
      elsif obj.is_a?(HappyMapper)
        h = {}
        obj.instance_variables.each do |var_name|
          key     = var_name.to_s.sub(/^@/, '').to_sym
          value   = obj.instance_variable_get(var_name)
          h[key]  = object_to_hash(value)
        end
        h
      elsif obj.respond_to?(:to_attrs)
        obj.to_attrs
      else
        obj.to_s
      end
    end

    def serve_output(output)
      output = object_to_hash(output)

      if @options.format && @options.format == "json"
        output = JSON.generate(output)
      end

      if @options.output
        Pathname(options.output).open("w+") do |f|
          f.write(output)
        end
      elsif print_output?
        puts output.to_s
      else
        output
      end
    end

    # for testing purposes
    # TODO: find a better way to do this
    def print_output?
      ENV['TESTING'].nil?
    end
  end
end
