# The Dsl builds up a temporary configuration structure
# which we iterate over to actually build up the various
# components.

module Datapimp::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :_desc,
                    :_current_api,
                    :_current_resource
    end
  end

  module ClassMethods
    DescriptionTargets = %w{version policy}

    # Allows you to describe the subsequent call in the DSL
    # for the purpose of generating easy / inspecting documentation
    def desc(description, options={})
      (self._desc ||= {}).merge(description: description, options: options)
    end

    def fetch_description
      _desc = (self._desc ||= {})

      [
        _desc.delete(:description),
        _desc.delete(:options)
      ]
    end

    def set_current_api api_object
      self._current_api = api_object
    end

    def current_api
      self._current_api
    end

    def set_current_resource resource_object
      self._current_resource = resource_object
    end

    def current_resource
      self._current_resource
    end
  end
end

def self.api(name, options={}, &block)
  api = Datapimp::Api.new(name, options)
  Datapimp::Api.set_current_api(api)
  Datapimp::Api.instance_eval(&block) if block_given?
  api
end

def self.resource(name, options={}, &block)
  resource = Datapimp::Resource.new(name, options) do
    self.api = Datapimp::Api.current_api
  end

  Datapimp::Resource.set_current_resource(resource)
  Datapimp::Api.set_current_resource(resource)

  Datapimp::Resource.instance_eval(&block) if block_given?

  resource
end
