module Datapimp
  module Command
    module Factory
      def self.generate_all(model, *actions)
        actions += [:update, :create, :destroy]

        actions
      end

      def self.generate(model, action, &block)
        class_name    = "#{ action.to_s.capitalize }#{ model.to_s }".camelize
        model_stub    = model.singularize.downcase
        klass         = class_name.constantize rescue nil

        if klass.nil?
          pattern_code  = Patterns.send(action, class_name: class_name, model_stub: model_stub, model_name: model.to_s)
          instance_eval(pattern_code)
        end

        klass         = class_name.constantize rescue nil
        klass.instance_eval(block) if block_given?

        klass
      end
    end

    module Patterns
      mattr_accessor :default_base_class

      def default_base_class
        base = defined?(::ApplicationCommand) ? ApplicationCommand : Datapimp::Command
        @@default_base_class || base 
      end

      def self.create options={}
       class_name = options.fetch(:class_name)
       model_stub = options.fetch(:model_stub, :params)
       model_name = options.fetch(:model_name)

        %Q{
          class ::#{ class_name } < #{ default_base_class }
            required do
              model :user
              hash :#{ model_stub } do
                string :* , :discard_invalid => false
              end
            end

            def execute
              #{ model_name }.create!(#{model_stub})
            end
          end
        }
      end

      def self.destroy options={}
       class_name = options.fetch(:class_name)
       model_stub = options.fetch(:model_stub, :params)
       model_name = options.fetch(:model_name)

        %Q{
          class ::#{ class_name } < #{ default_base_class }
            required do
              model :user
              hash :#{ model_stub } do
                string :* , :discard_invalid => false
              end
            end

            def execute
              id = #{ model_stub }.fetch("id")
              model = #{ model_name }.find(id)
              model.destroy
              model
            end
          end
        }
      end

      def self.update options={}
       class_name = options.fetch(:class_name)
       model_stub = options.fetch(:model_stub, :params)
       model_name = options.fetch(:model_name)

        %Q{
          class ::#{ class_name } < #{ default_base_class }
            required do
              model :user
              hash :#{ model_stub } do
                string :*
              end
            end

            def execute
              id = #{ model_stub }.fetch("id")
              model = #{ model_name }.find(id)
              model.update_attributes(#{model_stub})
              model
            end
          end
        }
      end
    end
  end
end
