class CachedModel < ActiveRecord::Base
  include Filterable
  include Mutatable
end
