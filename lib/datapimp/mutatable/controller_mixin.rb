module Datapimp
  module Mutatable
    module ControllerMixin

      def update
        if outcome.success?
          instance_variable_set("@#{ model_name }", outcome.result)
          render "#{ model_name.pluralize }/show"
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end
      end


      def create
        if outcome.success?
          instance_variable_set("@#{ model_name }", outcome.result)
          render "#{ model_name.pluralize }/show"
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end
      end

      def destroy
        if outcome.success?
          head 204
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end

      end
      protected
        def current_user_object
          respond_to?(:current_user) ? send(:current_user) : nil
        end

        def command_inputs
          base = {user: current_user_object}
          base[model_name] = permitted_params

          base
        end

        def permitted_params
          params.require(model_name).permit!
        end

        def outcome
          @command_inputs = command_inputs
          @outcome ||= command_class.run(@command_inputs)
        end

        def model_name
          self.class.to_s.gsub('Controller','').singularize.underscore
        end

        def command_class
          action      = action_name.capitalize
          base        = self.class.to_s.gsub('Controller','').singularize

          "#{ action }#{ base }".camelize.constantize
        end

    end

  end
end

