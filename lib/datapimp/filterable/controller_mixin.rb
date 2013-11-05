module Datapimp
  module Filterable
    module ControllerMixin
      extend ActiveSupport::Concern

      included do
        respond_to :json, :html
      end

      def index
        results = model_class.query(current_user, params)
        instance_variable_set("@#{ model_name.pluralize }", results)
        respond_with(results)
      end

      def show
        result = model_class.query(current_user, params).find(params[:id])
        instance_variable_set("@#{ model_name }", result)
        respond_with(result)
      end

      protected

        def model_class
          self.class.to_s.gsub('Controller','').singularize.camelize.constantize
        end
    end
  end
end
