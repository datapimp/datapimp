module Datapimp
  class Resource
    include Datapimp::Dsl

    attr_reader :commands_config,
                :serializers_config,
                :queries_config,
                :routes_config,
                :options,
                :name

    def initialize(name, options={})
      @name               = name
      @options            = options.dup
      @serializers_config = {}
      @commands_config    = {}
      @queries_config     = {}
      @routes_config      = {}
    end

    def self.command name, description, &block
    end

    def self.serializer name=:default, &block
    end

    def self.query name=:default, &block
    end

    def self.routes options={}, &block
    end

    def self.examples options={}, &block
    end
  end
end
