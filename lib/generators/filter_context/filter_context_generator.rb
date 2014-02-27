module Rails
  module Generators
    class FilterContextGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision :suffix => "FilterContext"

      class_option :parent, :type => :string, :desc => "The parent class for the generated filter context"

      def create_filter_context_file
        template 'filter_context.rb', File.join('app/contexts', class_path, "#{file_name}_filter_context.rb")
      end

      private

      def generate_id_method
        RUBY_VERSION =~ /1\.8/
      end

      def attributes_names
        [:id] + attributes.select { |attr| !attr.reference? }.map { |a| a.name.to_sym }
      end

      def association_names
        attributes.select { |attr| attr.reference? }.map { |a| a.name.to_sym }
      end

      def parent_class_name
        if options[:parent]
          options[:parent]
        elsif defined?(::ApplicationFilterContext)
          "ApplicationFilterContext"
        else
          "Datapimp::Filterable::Context"
        end
      end
    end
  end
end
