require "spec_helper"

class CustomCommand < Datapimp::Command
  required do
    string :test
    boolean :prepared
  end

  optional do
    model :owner, :class => "User"
    hash :params do
      optional do
        string :name, default: "default_value"
      end
    end
  end

  prepare_with do |inputs|
    inputs['prepared'] = true
  end

  def execute
    check if prepared
  end

  def check
    true
  end

end

describe Datapimp::Command do
  it "should track descendants" do
    Datapimp::Command.descendants.should include(CustomCommand)
  end

  it "should prepare the inputs" do
    CustomCommand.any_instance.should_receive(:check)
    CustomCommand.run test:"true"
  end

  it "should expose some metadata" do
    docs = CustomCommand.documentation
    docs.fields.should_not be_empty
  end
end
