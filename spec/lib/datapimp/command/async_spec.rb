require "spec_helper"

class AsyncCommand < Datapimp::Command
  run_asynchronously(throttle: 30.seconds)

  required do
    string :command
  end
end

describe Datapimp::Command::Async do
  it "should allow me to pass options" do
    AsyncCommand.async_config.should have_key(:throttle)
  end

  it "should define a worker class" do
    defined?(AsyncCommand::Worker).should == "constant"
  end

  it "should intercept calls to run" do
    AsyncCommand::Worker.should_receive(:perform_async).with(command:"test")
    AsyncCommand.run(command:"test")
  end

end
