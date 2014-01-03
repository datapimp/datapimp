begin
  require "active_support/core_ext"
  require 'hashie'
rescue
  require "rubygems"
  require "active_support/core_ext"
  require 'hashie'
end


require 'datapimp/version'

module Datapimp
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Filterable
  autoload :Mutatable
  autoload :Smoke
  autoload :Configuration

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

  def self.config
    Configuration
  end
end

Datapimp.eager_load!
