require "datapimp/filterable/context"
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
        include Datapimp::Filterable::Delegator
      end
    end
  end
end

unless defined?(::Filterable)
  module Filterable
    def self.included(base)
      base.send(:include, Datapimp::Filterable)
    end
  end

  module Filterable
    class Context < Datapimp::Filterable::Context
    end
  end
end
