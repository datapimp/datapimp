require 'keen'

module Datapimp::Sources
  class Keen < Datapimp::Sources::Base
    attr_reader :options

    def initialize(args, options)
      @collection = args.first
      @options    = options.to_mash
    end

    def to_s
      extraction(@collection)
    end

    def extraction(event_collection)
      client.extraction(event_collection).map(&:jsonify)
    end

    private

    def client
      @_client ||= ::Keen::Client.new(
        project_id: Datapimp.config.keen_project_id,
        read_key:   Datapimp.config.keen_read_key
      )
    end
  end
end
