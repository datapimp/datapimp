module Datapimp::SerializerExtensions
  extend ActiveSupport::Concern

  included do
    include Datapimp::Documentation
  end
end
