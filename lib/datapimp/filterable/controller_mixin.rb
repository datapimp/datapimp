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

          if filter_context.paginated?
          end

          render :json => query_results, :meta => index_meta_data
        end
      end

      def show
        if stale_object?
          response.headers['x-filter-context'] = filter_context.cache_key
          render :json => found_object, :meta => show_meta_data
        end
      end

      protected
        def show_meta_data
          {}
        end

        def index_meta_data
          {count: query_results.try(:length) || 0, page: params[:page], limit: params[:limit]}
        end

        def stale_object?
          found_object && stale?(last_modified: found_object.updated_at, etag: found_object)
        end

        def stale_query?
          stale?(etag: filter_context_etag)
        end

        def find_object
          filter_context.find(params[:id])
        end

        def found_object
          find_object
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
