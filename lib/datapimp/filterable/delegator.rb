module Datapimp
  module Filterable
    mattr_accessor :default_context_class

    def self.default_context_class
      @@default_context_class = case
                                when !!::Rails.application.config.action_controller.perform_caching
                                  Datapimp::Filterable::CachedContext
                                else
                                  Datapimp::Filterable::Context
                                end
    end

    module Delegator
      extend ActiveSupport::Concern

      module ClassMethods
        def filter_context_class
          "#{ self.to_s }FilterContext".camelize.constantize rescue Datapimp::Filterable.default_context_class
        end

        def filter_for_user user=nil, params={}
          filter_context_class.new(all,user,params)
        end

        def query user=nil, params={}
          if user.nil?
            user = auth_class.new
          end

          filter_for_user(user, params).execute
        end

        def auth_class
          defined?(::User) ? ::User : Object
        end

      end
    end
  end
end
