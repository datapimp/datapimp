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
          response.headers['x-filter-context'] = filter_context.cache_key
          render :json => query_results
        end
      end

      def show
        if stale_object?
          response.headers['x-filter-context'] = filter_context.cache_key
          render :json => found_object
        end
      end

      protected
        def stale_object?
          found_object && stale?(last_modified: found_object.updated_at, etag: found_object)
        end

        def stale_query?
          stale?(etag: filter_context_etag)
        end

        def found_object
          filter_context.find(params[:id])
        end

        def query_results
          filter_context.execute(self).records
        end

        def filter_context_etag
          @filter_context_etag ||= filter_context.etag
        end

        def filter_context
          return @filter_context if @filter_context
          @filter_context = model_class.filter_context_for_user(current_user, params.except(:controller,:format,:action))
          @filter_context.controller = self
          @filter_context
        end

        def model_name
          base = self.class.to_s.gsub('Controller','').split('::').last
          base.singularize.underscore.downcase
        end

        def model_class
          base = self.class.to_s.gsub('Controller','').split('::').last
          base.singularize.camelize.constantize
        end
    end
  end
end
