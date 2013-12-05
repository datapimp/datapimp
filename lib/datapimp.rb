begin
  require "active_support/core_ext"
rescue
  require "rubygems"
  require "active_support/core_ext"
end

require "datapimp/version"
require "datapimp/filterable"
require "datapimp/mutatable"
require "datapimp/clients"

module Datapimp
  extend ActiveSupport::Concern

  included do
    include Filterable
    include Mutatable
  end
end
