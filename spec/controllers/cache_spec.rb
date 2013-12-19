require "spec_helper"

describe "Response Caching" do
  before(:all) { @controller = CachedModelsController.new }

  let(:etag) { CachedModel.query(User.last,{}).etag }

  it "should return a 200 status" do
    get :index, :format => :json
    response.status.should == 200
  end

  it "should return a 304 status" do
    response_etag = %("#{Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(etag))}")
    request.env['HTTP_IF_NONE_MATCH'] = response_etag

    get :index, :format => :json
    response.status.should == 304
  end
end
