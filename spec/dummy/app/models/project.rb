class Project < ActiveRecord::Base
  include Filterable
  include Mutatable

  generate_command_classes :except => [:destroy]
end
