class User < ActiveRecord::Base
  include Mutatable
  include Filterable
end
