begin
  require "active_support/core_ext"
rescue
  require "rubygems"
  require "active_support/core_ext"
end


module Datapimp
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Filterable
  autoload :Mutatable
  autoload :Clients
  autoload :Version

  if defined?(::Rails)
    require "datapimp/engine"
    require "datapimp/railtie"
  end

  require "mutatable" unless defined?(::Mutatable)
  require "filterable" unless defined?(::Filterable)

  # Including the datapimp model in your controllers, or models
  # will include both the filterable and mutatable mixins
  included do
    include Filterable
    include Mutatable
  end
end

