class Datapimp::Clients::Github::Client
  attr_accessor :options, :cache

  InvalidAuth = Class.new(Exception)

  def initialize options={}
    @options = options
  end

  def github_token
    options.fetch(:github_token,impersonate_user.github_token)
  end

  def impersonate_user
    @impersonate_user ||= options.fetch(:user, nil)
  end

  def headers
    base = {
      "Authorization"   => "token #{ github_token }",
      "Accepts"         => "application/json"
    }

    base.merge(options[:headers] || {}).stringify_keys
  end

  def anonymous?
    !!(options[:public] || options[:anonymous])
  end

  def delete_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    RequestWrapper.new(type,params,headers).delete
  end

  def post_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    RequestWrapper.new(type,params,headers).post
  end

  def get_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    RequestWrapper.new(type,params,headers).get
  end

  def update_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    RequestWrapper.new(type,params,headers).update
  end

  class RequestWrapper
    attr_accessor :request,:headers,:params,:type, :method

    class_attribute :request_cache, :response_cache

    self.request_cache = Redis::HashKey.new("github_requests:etags:#{ Rails.env }")
    self.response_cache = Redis::HashKey.new("github_request:responses:#{ Rails.env }")

    def initialize(type,params,headers)
      @type = type
      @params = params
      @headers = headers
      @method = :get

      @cache_key = Digest::MD5.hexdigest([params.to_json, type].to_json)
    end

    def request
      if method == :get
        @request = Typhoeus::Request.new "https://api.github.com/#{ type }",
                                          method: method,
                                          headers: request_headers,
                                          params: params
      else
        @request = Typhoeus::Request.new "https://api.github.com/#{ type }",
                                         method: method,
                                         headers: request_headers,
                                         body: JSON.generate(params)
      end
    end

    def get
      @method = :get
      self
    end

    def update
      @method = :patch
      self
    end

    def post
      @method = :post
      self
    end

    def create
      @method = :post
      self
    end

    def delete
      @method = :delete
      self
    end

    def request_headers
      if method == :get && cached_etag.present? && cached_etag.length > 1
        @headers["If-None-Match"] = cached_etag.split('|').first
        @headers["If-Modified-Since"] = cached_etag.split('|').last
      end

      @headers
    end

    def cached_etag
      self.class.request_cache[cache_key]
    end

    def cache_key
      @cache_key
    end

    def cached?
      response.headers.try(:[],"Status") == "304 Not Modified"
    end

    def response
      return @response if @response

      @response = request.run

      if response.headers.try(:[],"Status") == "200 OK"
        self.class.request_cache[cache_key] = "#{response.headers.try(:[],"Etag")}|#{ response.headers.try(:[],"Last-Modified") }"
        self.class.response_cache[cache_key] = response.body
      end

      @response
    end

    def result
      @result ||= JSON.parse(response_body)
    end

    def response_body
      if cached?
        self.class.response_cache[cache_key]
      else
        response.body
      end
    end

    def records
      result
    end

    def to_object
      Hashie::Mash.new(result)
    end
  end
end
