module Datapimp::Clients::Github
  class Authentication
    attr_accessor :github_token

    InvalidAuth = Class.new(Exception)

    def initialize(options={})
      options.symbolize_keys! if options.is_a?(Hash)

      @github_token = case
      when options.respond_to?(:github_token)
        options.github_token
      when options.is_a?(Hash) && options.has_key?(:github_token)
        options[:github_token]
      when options.is_a?(Hash) && (options.has_key?(:username) && options.has_key?(:password))
        fetch_token options.values_at(:username,:password)
      when "#{ENV['GITHUB_TOKEN']}".length > 1
        ENV['GITHUB_TOKEN']
      else
        raise InvalidAuth
      end
    end

    protected

    def fetch_token

    end
  end
end
