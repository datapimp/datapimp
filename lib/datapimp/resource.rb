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

    def configure_command name, description, &block
      cfg = commands_config.fetch(name.to_sym) do
        {
          name: name,
          config_blocks: Set.new()
        }
      end

      cfg[:description] = description
      cfg[:config_blocks].push(&block)

      Datapimp::Command.configure(name, cfg)
    end

    def configure_serializer name, description, &block
      cfg = serializers_config.fetch(name.to_sym) do
        {
          name: name,
          config_blocks: Set.new()
        }
      end

      cfg[:description] = description
      cfg[:config_blocks].push(&block)

      Datapimp::Serializer.configure(name, cfg)
    end

    def configure_query name, description, &block
      cfg = serializers_config.fetch(name.to_sym) do
        {
          name: name,
          config_blocks: Set.new()
        }
      end

      cfg[:description] = description
      cfg[:config_blocks].push(&block)

      Datapimp::Query.configure(name, cfg)
    end

    def configure_routes options, &block
    end

    def configure_examples options, &block
    end

    # DSL Hooks
    #
    # The following class methods are called from the DSL
    # and route the necessary pieces to their place on the Resource Object itself
    def self.command name, description=nil, &block
      current_resource.configure_command(name, description, &block)
    end

    def self.serializer name=:default, description=nil, &block
      current_resource.configure_serializer(name, description, &block)
    end

    def self.query name=:default, description=nil, &block
      current_resource.configure_query(name, description, &block)
    end

    def self.routes options={}, &block
      current_resource.configure_routes(options, &block)
    end

    def self.examples options={}, &block
      current_resource.configure_examples(options, &block)
    end
  end
end
