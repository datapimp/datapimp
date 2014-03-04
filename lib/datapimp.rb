begin
  require "active_support/core_ext"
  require 'hashie'
rescue
  require "rubygems"
  require "active_support/core_ext"
  require 'hashie'
end


require 'datapimp/version'
require 'datapimp/configuration'

module Datapimp
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  def self.config
    Configuration
  end

  autoload :Filterable
  autoload :Mutatable
  autoload :Command
  autoload :CommandRunner
  autoload :Smoke
  autoload :QueryRunner

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

Datapimp.eager_load!
