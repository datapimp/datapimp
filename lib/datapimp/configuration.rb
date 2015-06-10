require 'singleton'
require 'json'

module Datapimp
  class Configuration
    include Singleton

    DefaultSettings = {
      manifest_filename: "datapimp.json",

      github_username: '',
      github_organization: '',
      github_app_key: '',
      github_app_secret: '',
      github_access_token: '',

      dnsimple_api_token: '',
      dnsimple_username: '',

      dropbox_app_key: '',
      dropbox_app_secret: '',
      dropbox_app_type: 'sandbox',
      dropbox_client_token: '',
      dropbox_client_secret: '',

      aws_access_key_id: '',
      aws_secret_access_key: '',
      aws_region: 'us-east-1',

      google_client_id: '',
      google_client_secret: '',
      google_refresh_token: '',
      google_access_token: ''
    }

    def current(using_environment = true)
      @current ||= calculate_config(using_environment)
    end

    def self.method_missing(meth, *args, &block)
      if instance.respond_to?(meth)
        return instance.send meth, *args, &block
      end

      nil
    end

    def method_missing(meth, *args, &block)
      if current.key?(meth.to_s)
        return current.fetch(meth)
      end

      super
    end

    def initialize!(fresh=false)
      return if home_config_path.exist? && !fresh

      FileUtils.mkdir_p home_config_path.dirname

      home_config_path.open("w+") do |fh|
        fh.write(DefaultSettings.to_json)
      end
    end

    def deploy_manifests_path
      Pathname(home_config_path.dirname).join("deploy-manifests").tap do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end

    def manifest_filename
      "datapimp.json"
    end

    def dnsimple_setup?
      dnsimple_api_token.to_s.length > 0 && dnsimple_username.to_s.length > 0
    end

    def dropbox_setup?
      dropbox_app_key.to_s.length > 0 && dropbox_app_secret.to_s.length > 0
    end

    def google_setup?
      google_client_secret.to_s.length > 0 && google_client_id.to_s.length > 0
    end

    def amazon_setup?
      aws_access_key_id.to_s.length > 0 && aws_secret_access_key.to_s.length > 0
    end

    def show
      current.each do |p|
        key, value = p

        unless key == 'sites_directory'
          puts "#{key}: #{ value.inspect }"
        end
      end
    end

    def primary_config
      cwd_config_path.exist? ? cwd_config : home_config
    end

    def get(setting)
      setting = setting.to_s.downcase
      primary_config[setting]
    end

    def set(setting, value, persist = true, options={})
      setting = setting.to_s.downcase
      primary_config[setting] = value
      save! if persist == true
      value
    end

    def apply_all(options={})
      current.merge!(options)
    end

    def unset(setting, persist = true)
      primary_config.delete(setting)
      save! if persist == true
    end

    def defaults
      DefaultSettings.dup
    end

    def calculate_config(using_environment = true)
      @current = defaults.merge(home_config.merge(cwd_config.merge(applied_config))).to_mash

      if ENV['DATAPIMP_CONFIG_EXTRA'].to_s.length > 0
        extra_config = Datapimp::Util.load_config_file(ENV['DATAPIMP_CONFIG_EXTRA'])
        @current.merge!(extra_config) if extra_config.is_a?(Hash)
      end

      (defaults.keys + home_config.keys + cwd_config.keys).uniq.each do |key|
        upper = key.to_s.upcase
        if ENV[upper]
          @current[key] = ENV[upper]
        end
      end if using_environment

      @current
    end

    def apply_config(hash={})
      applied_config.merge!(hash)
      current.merge(applied_config)
    end

    def apply_config_from_path(path)
      path = Pathname(path)
      parsed = JSON.parse(path.read) rescue {}
      applied_config.merge!(parsed)
      nil
    end

    def save!
      save_home_config
      save_cwd_config
      @current = nil
      true
    end

    def save_cwd_config
      return nil unless cwd_config_path.exist?

      File.open(cwd_config_path, 'w+') do |fh|
        fh.write JSON.generate(cwd_config.to_hash)
      end
    end

    def save_home_config
      File.open(home_config_path, 'w+') do |fh|
        fh.write JSON.generate(home_config.to_hash)
      end
    end

    # Applied config is configuration values passed in context
    # usually from the cli, but also in the unit tests
    def applied_config
      @applied_config ||= {}
    end

    def cwd_config
      @cwd_config ||= begin
        (cwd_config_path.exist? rescue false) ? JSON.parse(cwd_config_path.read) : {}
      rescue
        {}
      end
    end

    def home_config
      initialize! unless home_config_path.exist?

      @home_config ||= begin
        (home_config_path.exist? rescue false) ? JSON.parse(home_config_path.read) : {}
      rescue
        {}
      end
    end

    def home_config_path= value
      @home_config_path = Pathname(value)
    end

    def home_config_path
      @home_config_path || Pathname(ENV['HOME']).join(".datapimp", manifest_filename)
    end

    def cwd_config_path= value
      @cwd_config_path = Pathname(value)
    end

    def cwd_config_path
      @cwd_config_path || Pathname(Datapimp.pwd).join(manifest_filename)
    end
  end
end
