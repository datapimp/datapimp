require "active_support/core_ext"

require "datapimp/version"
require "datapimp/filterable"
require "datapimp/mutatable"

module Datapimp
  extend ActiveSupport::Concern

  included do
    include Filterable
    include Mutatable
  end
end
