require "spec_helper"

describe "The Controller Mixins" do

  before(:all) { @controller = ProjectsController.new }

  let(:sample) { Project.last }

  it "should return some projects" do
    get :index, :format => :json
    response.should be_success
    JSON.parse(response.body).should be_a(Array)
  end

  it "should find a record" do
    get :show, :id => sample.id, :format => :json
    response.should be_success
    assigns(:project).name.should == sample.name
  end

  it "should create a record" do
    post :create, :format => :json, :project => {name:"soederpop"}
    Project.where(name:"soederpop").should_not be_empty
    response.should be_success
  end

  it "should update a record" do
    ProjectsController.any_instance.should_receive(:after_update_success)
    put :update, id: sample.id, :format => :json, :project => {name:"boom son"}
    response.should be_success
  end

  it "should call the after create success callback" do
    ProjectsController.any_instance.should_receive(:after_create_success)
    post :create, :format => :json, :project => {name:"soederpop"}
  end
end
