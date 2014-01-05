require "spec_helper"

describe "Filterable Activity Monitoring" do
  before(:all) { @controller = CachedModelsController.new }

  let(:etag) { CachedModel.query(User.last,{}).etag }

  it "should show me all of the controllers which are monitoring activity" do
    list = Datapimp::Filterable::ActivityMonitoring.controllers
    list.should include(CachedModelsController)
  end

  it "should give me a report of all of the monitoring activity" do
    Datapimp::Filterable::ActivityMonitoring.controllers.map(&:activity_monitor_report).compact.should_not be_empty
  end

  it "interact with the activity monitor" do
    get :index, :format => :json
    response.status.should == 200
    activity_monitor = assigns(:activity_monitor)
    activity_monitor.should be_present
  end

  it "should return a 304 status" do
    response_etag = %("#{Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(etag))}")
    request.env['HTTP_IF_NONE_MATCH'] = response_etag

    get :index, :format => :json
    activity_monitor = assigns(:activity_monitor)

    response.status.should == 304
    activity_monitor.should be_present
  end
end
