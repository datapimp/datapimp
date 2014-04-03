require "spec_helper"

class HumanSerializer < ActiveModel::Serializer
  include Datapimp::Documentation

  desc :name, "The name of the human"
end

describe Datapimp::Documentation do
  it "should declare a name attribute" do
    HumanSerializer._attributes.should have_key(:name)
  end

  it "should document the name attribute" do
    HumanSerializer.documentation_for(:name).explanation.should == "The name of the human"
  end
end
