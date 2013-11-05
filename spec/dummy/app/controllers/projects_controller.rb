class ProjectsController < ApplicationController
  respond_to :json

  include Filterable
  include Mutatable

end
