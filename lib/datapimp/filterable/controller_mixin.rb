module Datapimp
  module Filterable
    module ControllerMixin
      extend ActiveSupport::Concern

      included do
        include ActivityMonitoring
        respond_to :json, :html
      end

      def index
        if stale_query?
          instance_variable_set("@#{ model_name.pluralize }", query_result)
          render :json => query_result.to_a
        end
      end

      def show
        if stale_object?
          instance_variable_set("@#{ model_name }", find_object)
          render :json => find_object
        end
      end

      protected
        def stale_object?
          find_object && stale?(last_modified: find_object.updated_at, etag: find_object)
        end

        def stale_query?
          stale?(etag: filter_context_etag)
        end

        def find_object
          filter_context.find(params[:id])
        end

        def query_result
          filter_context.execute
        end

        def filter_context_etag
          @filter_context_etag ||= filter_context.etag
        end

        def filter_context
          @filter_context ||= model_class.filter_for_user(current_user, params.except(:controller,:format,:action))
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
