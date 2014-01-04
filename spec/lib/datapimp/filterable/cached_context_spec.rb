require "spec_helper"

class PersonFilterContext < Datapimp::Filterable::CachedContext
  def build_scope
    self.scope
  end
end

class UserStub < User
  def id
    "userid1"
  end
end

describe Datapimp::Filterable::CachedContext do
  before(:each) do
    Rails.cache.clear
  end

  let(:filter) do
    PersonFilterContext.new(Person.all, UserStub.new, salary:35, something:"else")
  end

  describe "Anonymous Filter Contexts" do
    it "should know anonymous filter contexts" do
      PersonFilterContext.should be_anonymous
    end

    it "should include the userid in the cache key for not-anonymous contexts" do
      PersonFilterContext.not_anonymous
      filter.cache_key.should match(/userid1/)
      PersonFilterContext.anonymous
    end
  end

  it "cache the execute call" do
    filter.execute
    results = filter.execute
    results.should_not be_fresh
  end

  it "should return results" do
    filter.execute.should_not be_empty
  end

  it "should build a cache key from the params and scope attributes" do
    filter.cache_key.should include("salary:35","something:else")
  end

  it "should update the cache key if the underlying store changes" do
    old = filter.cache_key
    Person.last.update_attribute(:updated_at, Time.now + 10.minutes)
    filter.clone.cache_key.should_not == old
  end
end
