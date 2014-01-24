require "singleton"

module Datapimp
  class Configuration
    include Singleton

    Datapimp.define_singleton_method(:profile) do
      Datapimp.config.profile
    end

    cattr_accessor :root,
                   :config_path,
                   :current_profile,
                   :redis_connections,
                   :default_redis_connection

    @@root                      = nil
    @@config_path               = nil
    @@current_profile           = :default
    @@default_redis_connection  = $redis.presence
    @@redis_connections         = {}

    def self.default_redis_connection
      @@default_redis_connection || Redis.new
    end

    def self.profile
      Hashie::Mash.new(profiles[current_profile])
    end

    def self.profiles
      config_file.fetch(:profiles, {})
    end

    def self.config_file
      @config_file ||= if contents = IO.read(config_path) rescue nil
        structure = JSON.parse(contents)
        structure.is_a?(Hash) && structure.with_indifferent_access
      end
    end

    def self.config_path
      @@config_path ||(case
      when File.exists?(root.join('.datapimprc'))
        root.join('.datapimprc')
      when File.exists?(File.join(ENV['HOME'],'.datapimprc'))
        File.join(ENV['HOME'],'.datapimprc')
      end)
    end

    def self.root
      rails_root = ::Rails.root if defined?(::Rails)
      @@root || rails_root || Pathname.new(Dir.pwd().to_s)
    end

    def self.root=(path)
      @@root = Pathname.new(path.to_s) if path.present?
    end

    def self.redis_connection key, object=nil
      if object.present?
        redis_connections[key] = object
      end

      redis_connections.fetch(key) do
        default_redis_connection
      end
    end

  end

end

