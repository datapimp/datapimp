smoke "The Github Client" do
  let(:client) do
    Datapimp::Clients::Github.eager_load!
    Datapimp.github_client
  end

  it "should have an authentication token" do
    Datapimp.config.profile.github_token.present?
  end

  it "should obtain information about a user" do
    user_info = client.fetch(:user_info, user: "datapimp")
    user_info.email == "jon@chicago.com"
  end

  it "should access my private repos" do
    repo = client.fetch(:single_repository, repo: "skypager", user: "datapimp")
    repo.private == true
  end

  it "should obtain a client" do
    client.present?
  end

end
