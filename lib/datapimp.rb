libdir = File.join(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

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
require 'singleton'

module Datapimp
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  def self.config
    Configuration
  end

  autoload :Api
  autoload :Documentation
  autoload :SerializerExtensions
  autoload :Resource

  if defined?(::Rails)
    require "datapimp/engine"
    require "datapimp/railtie"
  end

end

require 'datapimp/filterable'
require 'datapimp/command'
Datapimp.eager_load!
