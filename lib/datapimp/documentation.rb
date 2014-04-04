module Datapimp
  module Documentation
    extend ActiveSupport::Concern

    require "datapimp/documentation/serializer_documenter"

    mattr_accessor :documented_serializers

    def self.documented_serializers
      @@documented_serializers ||= Set.new
    end

    included do
      if self < ActiveModel::Serializer
        include Datapimp::Documentation::SerializerDocumenter
      end
    end


    class Generator
      def self.documented_serializers
        ActiveModel::Serializer.descendants.select do |klass|
          binding.pry
        end
      end
    end
  end
end
