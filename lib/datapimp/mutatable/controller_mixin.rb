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
      extend ActiveSupport::Concern

      included do
        setup_hook_definitions_for(:before_create, :before_update, :before_destroy, :after_update, :after_create, :after_destroy)
      end

      module ClassMethods
        def setup_hook_definitions_for(*event_names)
          class_attribute :_mutations_hooks
          self._mutations_hooks ||= {}

          event_names.each do |event_name|
            self._mutations_hooks[event_name] ||= []

            instance_eval %Q{
              def #{ event_name }(&block)
                _mutations_hooks[event_name] << block
              end
            }
          end
        end
      end

      def update
        trigger(:before_update)

        if outcome_success?
          trigger(:after_update, instance_variable_set("@#{ model_name }", outcome_result), outcome, params)
          run_update_renderer
        else
          Rails.logger.error "Error on #{ model_name }#update"
          Rails.logger.error outcome.errors.message.inspect
          render :json => {success: false, errors: outcome.errors.message}, status: 422
        end
      end

      def create
        if outcome_success?
          trigger(:after_create, instance_variable_set("@#{ model_name }", outcome_result), outcome, params)
          run_create_renderer
        else
          Rails.logger.error "Error on #{ model_name }#create"
          Rails.logger.error outcome.errors.message.inspect
          render :json => {success: false, errors: outcome.errors.message}, status: 422
        end
      end

      def destroy
        if outcome_success?
          trigger(:after_destroy, outcome_result, outcome, params)
          head 204
        else
          render :json => {success: false, errors: outcome.errors.message}, status: 422
        end
      end

      protected

        def outcome_result
          outcome.result
        end

        def outcome_success?
          outcome.success?
        end

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
          render :json => outcome_result, status: :ok
        end

        def run_update_renderer_for_json
          render :json => outcome_result, status: :ok
        end

        def run_create_renderer_for_active_model_serializer
          render :json => outcome_result, status: :ok
        end

        def run_update_renderer_for_active_model_serializer
          render :json => outcome_result, status: :ok
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

          @command_inputs ||= base
        end

        def permitted_params
          params.require(model_name).permit!
        end

        def outcome
          return @outcome if @outcome

          @command_inputs = command_inputs
          @outcome = command_class.run(@command_inputs)
        end

        def model_name
          base = self.class.to_s.gsub('Controller','').split('::').last
          base.singularize.underscore
        end

        def command_class
          action      = action_name.capitalize
          base        = self.class.to_s.gsub('Controller','').split('::').last

          "#{ action }#{ base.singularize }".camelize.constantize
        end

        def trigger(event_name, *args)
          result, mutation_outcome, request_params = args

          if event_name.to_s.match(/^after/)
            # LEGACY Support
            # Will be deprecated in favor of hooks style
            self.send("#{ event_name }_success", result, mutation_outcome) if respond_to?("#{ event_name }_success")
          end

          run_hooks(event_name, result, mutation_outcome)
        end

        def run_hooks event_name, *args
          hooks = Array(self.class._mutations_hooks[event_name])

          hooks.each do |block|
            block.call(*args)
          end
        end

    end

  end
end

