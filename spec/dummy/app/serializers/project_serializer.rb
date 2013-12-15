require 'rubygems'
require 'active_model/serializer'

class ProjectSerializer < ActiveModel::Serializer
  attributes :name,
             :using_serializer


  def using_serializer
    true
  end
end
