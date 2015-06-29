require 'spec_helper'
require 'datapimp/sources/pivotal'

describe Datapimp::Sources::Pivotal do
  let(:options) { double('options', limit: 5, offset: nil, format: nil, output: nil).as_null_object }
  let(:project) { '442903' }

  describe "user activity" do
    it "should return an array of activities" do
      service = described_class.new([project], options)

      VCR.use_cassette(:pivotal_user_activity) do
        output = service.to_s

        expect(output).to be_kind_of(Hash)
        %w(user_activity project_activity project_stories).each do |key|
          expect(output).to have_key(key)
        end
      end
    end
  end
end
