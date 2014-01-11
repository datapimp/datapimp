require "spec_helper"

describe "The Controller Mixins" do

  before(:all) { @controller = ProjectsController.new }

  let(:sample) { Project.last }

  it "should return some projects" do
    get :index, :format => :json
    response.should be_success
    JSON.parse(response.body)["projects"].should_not be_empty
  end

  it "should use the serializer" do
    get :index, :format => :json
    project = JSON.parse(response.body)["projects"].first
    project.should have_key("using_serializer")
  end

  it "should find a record by id" do
    3.times.map { |n| Project.create(name:"Sheeit #{ n }") }.each do |sample|
      get :show, :id => sample.id, :format => :json
      response.should be_success
      assigns(:project).name.should == sample.name
    end
  end


  it "should create a record" do
    $k = true
    post :create, :format => :json, :project => {name:"soederpop"}
    $k = false
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
