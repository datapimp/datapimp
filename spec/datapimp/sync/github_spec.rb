require 'spec_helper'
require 'datapimp/sync/github'

describe Datapimp::Sync::Github do
  let(:options)     { double('options', limit: 5, offset: nil, format: nil, output: nil, relations: ["comments"]) }
  let(:repository)  { "architects/githubfs-test" }

  describe "issues" do
    it "should return an array of issues" do
      service = Datapimp::Sync::Github.new(repository, options)

      VCR.use_cassette(:github_issues) do
        output = service.sync_issues
        expect(output).to be_kind_of(Array)
      end
    end
  end
end
