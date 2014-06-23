require "spec_helper"

class CustomCommand < Datapimp::Command

  summarize_with "This is a custom command"

  describe_with "This is a longer description of the custom comand.  You would want to do this if..."

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
  it "should allow me to describe and summarize it" do
    CustomCommand.description.length.should >= 10
    CustomCommand.summary.length.should >= 10
  end

  it "should track descendants" do
    Datapimp::Command.descendants.should include(CustomCommand)
  end

  it "should prepare the inputs before running the command" do
    CustomCommand.any_instance.should_receive(:check)
    CustomCommand.run test:"true"
  end

  describe "Current User Awareness" do

    it "should allow me to pass in current user as a traditional mutations dsl argument" do
      class UserAware < Datapimp::Command
        required do
          integer :value
        end

        def execute
          value + current_user
        end
      end

      UserAware.run(value:1, current_user: 2).result.should == 3
    end

    it "should allow me pass a block to the run command" do
      outcome = UserAware.run(value:1) do
        run_as(2)
      end

      outcome.result.should == 3
    end
  end

  describe "Documentation and Command Metadata" do
    it "should expose some metadata" do
      docs = CustomCommand.to_documentation
      docs.fields.should_not be_empty
      docs.group.should be_present
    end

    it "should belong to a group" do
      CustomCommand.to_documentation.group.should == "commands"
    end

    it "should expose an alias" do
      CustomCommand.to_documentation.alias.should == "commands:custom"
    end
  end
end
