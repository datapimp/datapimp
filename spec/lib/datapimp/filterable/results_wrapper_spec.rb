require "spec_helper"

class PersonFilterContext < Datapimp::Filterable::CachedContext
  def build_scope
    self.scope
  end

  def boom
    "boom"
  end
end

describe Datapimp::Filterable::ResultsWrapper do
  let(:results) do
    PersonFilterContext.new(Person.all, User.new, salary:35, something:"else").execute
  end

  it "should delegate to the filter context" do
    results.boom.should == "boom"
  end

  it "should delegate to the underlying scope" do
    results.to_sql.should match('SELECT')
  end

  it "should render the results as JSON" do
    results.to_json.should be_a(String)
    JSON.parse(results.to_json).should be_an(Array)
  end

  it "should return the max updated time stamp for the results" do
    results.last_modified.should respond_to(:strftime)
  end

end
