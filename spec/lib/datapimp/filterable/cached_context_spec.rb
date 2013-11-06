require "spec_helper"

class PersonFilterContext < Datapimp::Filterable::CachedContext
  def build_scope
    self.scope
  end
end

describe Datapimp::Filterable::CachedContext do
  before(:each) do
    Rails.cache.clear
  end

  let(:filter) do
    PersonFilterContext.new(Person.all, User.new, salary:35, something:"else")
  end

  it "cache the execute call" do
    filter.should_receive(:wrap_results).once
    2.times { filter.execute }
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
