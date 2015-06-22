require 'datapimp/sync/base'
require 'keen'

module Datapimp::Sync
  class Keen < Base
    def initialize(options)
      super(options)
    end

    # Keen.multi_analysis("purchases",
    #   analyses: {
    #     gross: {
    #       analysis_type: "sum",
    #       target_property: "price"
    #     },
    #     customers: {
    #       analysis_type: "count_unique",
    #       target_property: "username"
    #     }
    #   },
    #   timeframe: 'today',
    #   group_by: "item.id"
    # ) # => [{ "item.id" => 2, "gross" => 314.49, "customers" => 8 } }]
    def multi_analysis(query)
      #TODO
    end

    def extraction(event_collection)
      serve_output(client.extraction(event_collection))
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
