# The `Datapimp::Sync` module will delegate to the underlying service layer
# which we are pushing or pulling files and data from.  It will wrap the client
# implementation we are using.
module Datapimp
  module Sync
    def self.data_source_types
      %w(dropbox amazon github google json excel nokogiri)
    end

    def self.amazon(options={})
      require 'datapimp/clients/amazon'
      Datapimp::Clients::Amazon.client(options)
    end

    def self.dropbox(options={})
      require 'datapimp/clients/dropbox'
      Datapimp::Clients::Dropbox.client(options)
    end

    def self.github(options={})
      require 'datapimp/clients/github'
      Datapimp::Clients::Github.client(options)
    end

    def self.google(options={})
      require 'datapimp/clients/google'
      Datapimp::Clients::Google.client(options)
    end
  end
end
