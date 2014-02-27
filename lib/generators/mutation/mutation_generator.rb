module Rails
  module Generators
    class MutationGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision :suffix => "Mutation"

      class_option :parent, :type => :string, :desc => "The parent class for the generated mutation"

      def create_filter_context_file
        template 'mutation.rb', File.join('app/mutations', class_path, "#{file_name}.rb")
      end

      private

      def generate_id_method
        RUBY_VERSION =~ /1\.8/
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
