module Datapimp
  module Filterable
    mattr_accessor :default_context_class

    def self.default_context_class
      @@default_context_class || ApplicationFilterContext
    end

    module ContextDelegator
      extend ActiveSupport::Concern

      module ClassMethods
        def filter_context_class
          "#{ self.to_s.split('::').last }FilterContext".camelize.constantize rescue Datapimp::Filterable.default_context_class
        end

        def filter_context_for_user user=nil, params={}
          filter_context_class.new(all,user,params)
        end

        def query user=nil, params={}
          if user.is_a?(Hash) && !user.empty? && params.empty?
            params = user
            user = nil
          end

          user = auth_class.new if user.nil?

          filter_context_for_user(user, params).execute
        end

        def auth_class
          defined?(::User) ? ::User : Object
        end

      end
    end
  end
end

class ApplicationFilterContext < Datapimp::Filterable::Context
end
