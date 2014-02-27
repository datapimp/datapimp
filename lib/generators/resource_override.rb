require "rails/generators"
require "rails/generators/rails/resource/resource_generator"

module Rails
  module Generators
    ResourceGenerator.class_eval do
      def add_filter_context
        invoke "filter_context"
      end

      def add_mutation
        invoke "mutation"
      end
    end
  end
end

