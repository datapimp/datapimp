require 'typhoeus'
require 'datapimp/clients/github/request_wrapper'

class Datapimp::Clients::Github::Client
  attr_accessor :options, :cache

  InvalidAuth = Class.new(Exception)

  def initialize options={}
    @options = options
  end

  def request_wrapper_class
    Datapimp::Clients::Github::RequestWrapper
  end

  def fetch(request_type,*args)
    fetch_request_object(request_type, *args).to_object
  end

  def fetch_request_object request_type, *args
    options = args.extract_options!
    request_type = request_type.to_s.camelize

    if request_klass = Datapimp::Clients::Github.const_get(request_type) rescue nil
      request_klass.new(options)
    end
  end

  def github_token
    options.fetch(:github_token, impersonate_user.try(:github_token))
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

    request_wrapper_class.new(type,params,headers).delete
  end

  def post_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    request_wrapper_class.new(type,params,headers).post
  end

  def get_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    request_wrapper_class.new(type,params,headers).get
  end

  def update_request type, params={}
    if !github_token.present? && !anonymous?
      raise InvalidAuth
    end

    request_wrapper_class.new(type,params,headers).update
  end

end
