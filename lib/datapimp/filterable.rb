require "datapimp/filterable/results_wrapper"
require "datapimp/filterable/cache_statistics"
require "datapimp/filterable/activity_monitor"
require "datapimp/filterable/context"
require "datapimp/filterable/cached_context"
require "datapimp/filterable/delegator"
require "datapimp/filterable/controller_mixin"

module Datapimp
  module Filterable
    extend ActiveSupport::Concern

    included do
      case
      when ancestors.include?(ActionController::Base)
        include Datapimp::Filterable::ControllerMixin
      when ancestors.include?(ActiveRecord::Base)
        include Datapimp::Filterable::ContextDelegator
      end
    end
  end
end
