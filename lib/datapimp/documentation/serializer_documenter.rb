module Datapimp::Documentation::SerializerDocumenter
  extend ActiveSupport::Concern

  included do
    class_attribute :_documentation
    self._documentation ||= Hashie::Mash.new({})
    Datapimp::Documentation.documented_serializers << name.to_sym
  end

  module ClassMethods
    def documentation_for(attribute, options={})
      Hashie::Mash.new documentation[:documentation].fetch(attribute.to_sym)
    end

    def documentation
      @documentation ||= {
        schema: schema,
        documentation: format_documentation
      }
    end

    def desc property, explanation=nil, *args, &block
      options = args.extract_options!

      if options[:has_many]
        has_many property
      elsif options[:has_one]
        has_one property
      elsif
        attribute(property)
      end

      _documentation[property] = {
        explanation: explanation,
        options: options
      }
    end

    def format_documentation
      # TODO
      # Make the return valu a little nicer
      raw = _documentation

      raw.keys.each do |attribute|
        config = schema[:attributes][attribute]
        raw[attribute][:type] ||= config if config.is_a?(Symbol)
      end

      raw
    end
  end
end
