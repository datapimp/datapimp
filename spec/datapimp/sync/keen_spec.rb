require 'spec_helper'
require 'datapimp/sources/keen'

describe Datapimp::Sources::Keen do
  let(:options) { double('options', limit: 5, offset: nil, format: nil, output: nil).as_null_object }

  describe "Extraction" do
    it "should return an array with all property values" do
      service = described_class.new(['purchases'], options)

      VCR.use_cassette(:keen_extraction) do
        output = service.to_s
        expect(output).to be_kind_of(Array)
      end
    end
  end
end
