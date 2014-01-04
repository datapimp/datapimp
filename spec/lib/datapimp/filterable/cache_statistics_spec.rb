require "spec_helper"

class PersonFilterContext < Datapimp::Filterable::CachedContext
  cached

  def build_scope
    self.scope
  end
end

class UserStub < User
  def id
    "userid1"
  end
end

describe Datapimp::Filterable::CacheStatistics do
  before(:each) do
    Rails.cache.clear
  end

  let(:filter) do
    PersonFilterContext.new(Person.all, UserStub.new, salary:35, something:"else")
  end

  it "should know if it is cached" do
    filter.should be_cached
  end

  it "should provide a report" do
    Rails.cache.clear
    filter.clear_cache_stats
    3.times { filter.execute }
    filter.cache_stats_report[:ratio].should == "33.33"
  end

  it "should be able to track cache stats" do
    filter.should respond_to(:record_cache_hit)
    filter.should respond_to(:record_cache_miss)
  end
end

