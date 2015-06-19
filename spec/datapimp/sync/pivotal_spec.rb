require 'spec_helper'
require 'datapimp/sync/pivotal'

describe Datapimp::Sync::Pivotal do
  let(:options) { double('options', limit: 5, offset: nil, format: nil, output: nil) }

  describe "user activity" do
    it "should return an array of activities" do
      service = Datapimp::Sync::Pivotal.new(options)

      VCR.use_cassette(:user_activity) do
        output = service.user_activity
        expect(output).to be_kind_of(Array)
      end
    end
  end
end
