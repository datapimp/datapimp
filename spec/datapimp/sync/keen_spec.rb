require 'spec_helper'
require 'datapimp/sync/keen'

describe Datapimp::Sync::Keen do
  let(:options) { double('options', limit: 5, offset: nil, format: nil, output: nil) }

  describe "Extraction" do
    it "should return an array with all property values" do
      service = Datapimp::Sync::Keen.new(options)

      VCR.use_cassette(:keen_extraction) do
        output = service.extraction('purchases')
        expect(output).to be_kind_of(Array)
      end
    end
  end
end
