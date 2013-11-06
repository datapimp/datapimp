require "spec_helper"

describe Datapimp::Filterable do

  before(:all) do
    Person.send(:include, Filterable)
  end

  it "should define an easy include" do
    defined?(Filterable).should == "constant"
  end

  it "should provide a query method" do
    Person.should respond_to(:query)
  end

  it "should return the last modified stamp" do
    Person.query({}).should respond_to(:last_modified)
  end

end
