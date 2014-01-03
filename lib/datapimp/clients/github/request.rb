class Datapimp::Clients::Github::Request

  attr_accessor :options, :user, :org, :repo, :params, :headers, :github_token

  def initialize(options={})
    @options = options.dup

    @user, @org, @repo, @github_token = options.values_at(:user,:org,:repo,:github_token)
    @params   = options[:params] || {}
    @headers  = options[:headers] || {}

    @user ||= Datapimp.config.profile.github_nickname
    @org ||= Datapimp.config.profile.github_organization
  end

  def to_object
    records.is_a?(Array) ? all : Hashie::Mash.new(records)
  end

  def object
    records
  end

  def all
    @all ||= records.map {|r| Hashie::Mash.new(r) }
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
    if impersonate_user.present?
      return @client ||= Datapimp::Clients::Github::Client.new(user: impersonate_user, headers: headers, github_token: github_token)
    end

    @client ||= Datapimp.github_client
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
    (@org.nil? || @org.empty?) ? user : @org
  end

  protected
    def github_token
      @github_token || impersonate_user.try(:github_token) || Datapimp.config.profile.github_token
    end

    def endpoint
      "users/#{ user }"
    end

    def impersonate_user
      if defined?(::User) && ::User.respond_to?(:find_by_github_nickname)
        @impersonate_user ||= ::User.find_by_github_nickname(user)
      end
    end
end
