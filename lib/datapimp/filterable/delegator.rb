module Datapimp
  module Filterable
    module Delegator
      extend ActiveSupport::Concern

      module ClassMethods
        def filter_context_class
          "#{ self.to_s }FilterContext".camelize.constantize rescue Filterable::Context
        end

        def filter_for_user user=nil, params={}
          filter_context_class.new(all,user,params).execute
        end

        def query user=nil, params={}
          if user.nil?
            user = auth_class.new
          end

          filter_for_user(user, params)
        end

        def auth_class
          defined?(::User) ? ::User : Object
        end

      end
    end
  end
end
