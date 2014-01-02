class Project < ActiveRecord::Base
  include Datapimp
  generate_command_classes :except => [:destroy]
end
