require "spec_helper"

class ContextHelper < ActiveRecord::Base
  self.table_name = :people
  include Filterable
end

describe Datapimp::Filterable::Context do
  it "should retain the params" do
    ContextHelper.query(param:"value").params.should have_key(:param)
  end
end

