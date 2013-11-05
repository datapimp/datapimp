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

  it "should produce a filterable context" do
    Datapimp::Filterable::Context.any_instance.should_receive(:execute)
    Person.query({})
  end

end
