require "mutations"
require "datapimp/mutatable/controller_mixin"
require "datapimp/mutatable/command_factory"

module Datapimp
  module Mutatable
    extend ActiveSupport::Concern

    included do
      case
      when ancestors.include?(ActionController::Base)
        include ControllerMixin
      when ancestors.include?(ActiveRecord::Base)
        extend ModelExtensions
      end
    end

    module ModelExtensions
      def generate_command_classes options={}
        only = options.fetch(:only, ["create","update","destroy"])
        except = options.fetch(:except, [])

        (only - except).each do |action|
          Datapimp::Mutatable::CommandFactory.generate(self.to_s,action)
        end
      end
    end

  end
end

module Mutatable
  def self.included(base)
    base.send(:include, Datapimp::Mutatable)
  end
end unless defined?(::Mutatable)
