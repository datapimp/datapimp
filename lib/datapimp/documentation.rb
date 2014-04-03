module Datapimp
  module Documentation
    require "datapimp/documentation/serializer_documenter"

    extend ActiveSupport::Concern

    included do
      if self < ActiveModel::Serializer
        include Datapimp::Documentation::SerializerDocumenter
      end
    end
  end
end
