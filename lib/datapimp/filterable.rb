module Datapimp
  module Filterable
    extend ActiveSupport::Concern

    included do
      include Datapimp::Filterable::ContextDelegator
    end
  end
end

require 'datapimp/filterable/context'
require 'datapimp/filterable/cache_statistics'
require 'datapimp/filterable/cached_context'
require 'datapimp/filterable/context_delegator'
require 'datapimp/filterable/results_wrapper'
