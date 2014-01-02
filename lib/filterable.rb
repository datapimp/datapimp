module Filterable
  def self.included(base)
    base.send(:include, Datapimp::Filterable)
  end
end

module Filterable
  class Context < Datapimp::Filterable::Context
  end
end


