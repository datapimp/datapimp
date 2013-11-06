module Datapimp
  module Filterable
    module ControllerMixin
      extend ActiveSupport::Concern

      included do
        respond_to :json, :html
      end

      def index
        if stale? last_modified: filter_context.last_modified
          results = model_class.query(current_user, params)
          instance_variable_set("@#{ model_name.pluralize }", results)
          respond_with(results)
        end
      end

      def show
        result = filter_context.find(params[:id])

        if stale? last_modified: result.updated_at, etag: result
          instance_variable_set("@#{ model_name }", result)
          respond_with(result)
        end
      end

      protected
        def filter_context
          model_class.filter_for_user(current_user, params)
        end

        def model_name
          self.class.to_s.gsub('Controller','').singularize.underscore.downcase
        end

        def model_class
          self.class.to_s.gsub('Controller','').singularize.camelize.constantize
        end
    end
  end
end
