module Datapimp
  module Mutatable

    mattr_accessor :renderer_strategy

    def self.renderer_strategy
      return @@renderer_strategy if @@renderer_strategy

      case
        when defined?(ActiveModel::Serializer)
          :active_model_serializer
        when defined?(Jbuilder)
          :jbuilder
        else
          :format
      end
    end

    module ControllerMixin
      def update
        if outcome.success?
          instance_variable_set("@#{ model_name }", outcome.result)
          self.send(:after_update_success, outcome, outcome.result) if respond_to?(:after_update_success)
          run_update_renderer
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end
      end


      def create
        if outcome.success?
          instance_variable_set("@#{ model_name }", outcome.result)
          self.send(:after_create_success, outcome, outcome.result) if respond_to?(:after_create_success)
          run_create_renderer
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end
      end

      def destroy
        if outcome.success?

          self.send(:after_destroy_success, outcome, outcome.result) if respond_to?(:after_destroy_success)

          head 204
        else
          render :json => {success: false, errors: outcome.errors.symbolic}, status: 422
        end

      end

      protected
        # TODO
        # This can be a lot cleaner with  little metaprogramming
        def renderer_strategy
          strategy = Datapimp::Mutatable.renderer_strategy
          strategy = params.fetch(:format, :json) if strategy == :format
          strategy
        end

        def run_update_renderer
          meth = "run_update_renderer_for_#{ renderer_strategy }".to_sym
          self.send(meth) rescue self.send(:run_create_renderer_for_json)
        end

        def run_create_renderer
          meth = "run_create_renderer_for_#{ renderer_strategy }".to_sym
          self.send(meth) rescue self.send(:run_create_renderer_for_json)
        end

        def run_create_renderer_for_json
          render :json => outcome.result, status: :ok
        end

        def run_update_renderer_for_json
          render :json => outcome.result, status: :ok
        end

        def run_create_renderer_for_active_model_serializer
          render :json => outcome.result, status: :ok
        end

        def run_update_renderer_for_active_model_serializer
          render :json => outcome.result, status: :ok
        end

        def run_create_renderer_for_js
          render "#{ model_name.pluralize }/show"
        end

        def run_create_renderer_for_js
          render "#{ model_name.pluralize }/show"
        end

        def run_create_renderer_for_jbuilder
          render "#{ model_name.pluralize }/show"
        end

        def run_update_renderer_for_jbuilder
          render "#{ model_name.pluralize }/show"
        end

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

