module Datapimp
  module Filterable
    mattr_accessor :default_context_class

    def self.default_context_class
      return @@default_context_class if @@default_context_class
      return ApplicationFilterContext if defined?(ApplicationFilterContext)

      if !!::Rails.application.config.action_controller.perform_caching
        class_eval("class ::ApplicationFilterContext < Datapimp::Filterable::CachedContext; end")
      else
        class_eval("class ::ApplicationFilterContext < Datapimp::Filterable::Context; end")
      end

      @@default_context_class = ApplicationFilterContext
    end

    module ContextDelegator
      extend ActiveSupport::Concern

      module ClassMethods
        def filter_context_class
          "#{ self.to_s }FilterContext".camelize.constantize rescue Datapimp::Filterable.default_context_class
        end

        def filter_for_user user=nil, params={}
          filter_context_class.new(all,user,params)
        end

        def query user=nil, fc=nil, params={}
          params = fc if fc.is_a?(Hash)
          fc = nil unless fc.kind_of?(filter_context_class)

          if user.is_a?(Hash) && !user.empty? && params.empty?
            params = user
            user = nil
          end

          if user.nil?
            user = auth_class.new
          end

          fc ||= filter_for_user(user, params)

          fc.execute
        end

        def auth_class
          defined?(::User) ? ::User : Object
        end

      end
    end
  end
end
