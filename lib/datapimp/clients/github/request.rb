class Datapimp::Clients::Github::Request

  attr_accessor :options, :user, :org, :repo, :params, :headers, :github_token

  def initialize(options={})
    @options = options.dup

    @user, @org, @repo, @github_token = options.values_at(:user,:org,:repo,:github_token)
    @params   = options[:params] || {}
    @headers  = options[:headers] || {}
  end

  def all
    @all ||= records.map {|r| Hashie::Mash.new(r) }
  end

  def object

  end

  def create params={}
    client.post_request(endpoint, params).request.run
  end

  def update record_id, params={}
    client.update_request("#{ endpoint }/#{ record_id }", params).request.run
  end

  def destroy record_id, params={}
    client.delete_request("#{ endpoint }/#{ record_id }").request.run
  end

  def show record_id, params={}
    client.get_request("#{ endpoint }/#{ record_id }", params).to_object
  end

  def client
    @client ||= GithubClient.new(user: impersonate_user, headers: headers, github_token: github_token)
  end

  def records
    @records = request.records
  end

  def results
    records
  end

  def result
    records
  end

  def request
    @request ||= client.get_request(endpoint, params)
  end

  def org
    @org
  end

  protected
    def github_token
      @github_token || impersonate_user.github_token || Datapimp::Clients::Github.default_github_token
    end

    def endpoint
      "users/#{ user }"
    end

    def impersonate_user
      if User.respond_to?(:find_by_github_nickname)
        @impersonate_user ||= User.find_by_github_nickname(user)
      end
    end
end
