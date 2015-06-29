require 'spec_helper'
require 'datapimp/sources/github_repository'

describe Datapimp::Sources::GithubRepository do
  let(:options)     { double('options', limit: 5, offset: nil, format: nil, output: nil, relations: ["comments"]).as_null_object }
  let(:repository)  { "architects/githubfs-test" }

  describe "issues" do
    it "should return an array of issues" do
      service = described_class.new(repository, options)

      VCR.use_cassette(:github_issues) do
        output = service.to_s
        expect(output).to be_kind_of(Hash)
        expect(output).to have_key('issues')
      end
    end
  end
end
