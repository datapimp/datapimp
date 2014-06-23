module Datapimp
  class Api
    include Datapimp::Dsl

    attr_accessor :resources,
                  :policies,
                  :version_config,
                  :name,
                  :options

    def initialize(name, options={})
      @options    = options.dup
      @name       = name.to_s
      @policies   = {}
      @resources  = {}
    end

    def configure_policy policy_name, options={}, &block
      policy = policies.fetch(policy_name.to_sym) do
        Datapimp::Api::Policy.new(options.reverse_merge(name: policy_name))
      end

      policy.apply_options(options)
      policy.instance_eval(&block) if block_given?

      policy
    end

    def self.version value, options={}
      description, _opts  = fetch_description

      current_api.version_config = {
        value: value.to_s,
        options: options || {},
        description: description.to_s
      }
    end

    def self.policy name, options={}
      description, _opts = fetch_description

      options[:description] ||= description
      current_api.configure_policy(name, options)
    end
  end
end

require 'datapimp/api/policy'
