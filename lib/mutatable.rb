module Mutatable
  def self.included(base)
    base.send(:include, Datapimp::Mutatable)
  end
end


