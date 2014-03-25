module Rails
  module Generators
    class MutationGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision :suffix => "Mutation"

      class_option :parent, :type => :string, :desc => "The parent class for the generated mutation"
      class_option :actions, :type => :string, :desc => "Comma separated list of actions to generate commands for. default: create,update,destroy"

      def create_mutation_file
        command_actions.each do |action|
          destination = File.join('app/commands', class_path, "#{action}_#{file_name}.rb")
          @action = action
          @mutation_base = file_name
          template 'mutation.rb', destination
        end
      end

      private

      def generate_id_method
        RUBY_VERSION =~ /1\.8/
      end

      def command_actions
        if options[:actions]
          options[:actions].to_s.split(',').map(&:strip).map(&:downcase)
        else
          %w{create destroy update}
        end
      end

      def mutation_resource_identifier
        @mutation_base.underscore.downcase
      end

      def mutation_class_name
        [@action, @mutation_base].join("_").camelize
      end

      def parent_class_name
        if options[:parent]
          options[:parent]
        elsif defined?(::ApplicationCommand)
          "ApplicationCommand"
        elsif defined?(::Datapimp::Command)
          "Datapimp::Command"
        else
          "Mutations::Command"
        end
      end
    end
  end
end
