require "spec_helper"

class ContextHelper < ActiveRecord::Base
  self.table_name = :people
  include Filterable
end

describe Datapimp::Filterable::Context do
  it "should retain the params" do
    ContextHelper.query(param:"value").params.should have_key(:param)
  end

  it "should use the ApplicationFilterContext by default" do
    class ApplicationFilterContext < Datapimp::Filterable::CachedContext
      def sheeeeit
        "main"
      end
    end

    ContextHelper.query.filter_context.should be_kind_of(ApplicationFilterContext)
    ContextHelper.query.filter_context.sheeeeit.should == "main"
  end

end

