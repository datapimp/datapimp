require "filterable/context"
require "filterable/delegator"
require "filterable/controller"

module Filterable
  extends ActiveSupport::Concern

  included do
    case
    when ancestors.include?(ActionController::Base)
      include Filterable::Controller
    when ancestors.include?(ActiveRecord::Base)
      include Filterable::Delegator
    end
  end
end
