require "spec_helper"

describe Datapimp::Mutatable do
  before(:all) do
    Person.send(:include, Mutatable)
    Person.send(:generate_command_classes)
  end

  it "should provide an easy include" do
    defined?(Mutatable).should == "constant"
  end

  it "should generate some mutation command classes where they don't exist" do
    defined?(CreatePerson).should == "constant"
  end

end
