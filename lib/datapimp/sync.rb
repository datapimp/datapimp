# The `Datapimp::Sync` module will delegate to the underlying service layer
# which we are pushing or pulling files and data from.  It will wrap the client
# implementation we are using.
module Datapimp
  module Sync
    def self.data_source_types
      %w(dropbox amazon github google json excel nokogiri)
    end

    def self.dispatch_sync_data_action(args, options)
      source  = args.first
      type    = options[:type]

      result = case type
               when "github"
                 Datapimp::Sources::GithubRepository.new(source, options)
               when "google" || "google-spreadsheet"
                 require 'google_drive'
                 Datapimp::Sources::GoogleSpreadsheet.new(nil, key: source)
               when "pivotal" then
                 Datapimp::Sources::Pivotal.new(args, options)
               when "keen" then
                 Datapimp::Sources::Keen.new(args, options)
               end
      result
    end

    # Create any type of syncable folder and dispatch a run call to it
    # with whatever options you want.
    #
    # options:
    #   - local: relative path to th local version of this folder
    #   - remote: an identifier for the remote folder in the remote system
    #   - action: push, pull, etc
    def self.dispatch_sync_folder_action(local, remote, options)
      options = options.to_mash
      action = options.action

      folder = case
               when options.type == "dropbox"
                 Datapimp::Sync::DropboxFolder.new(local: local, remote: remote)
               when options.type == "google"
                 # Return the folders
                 # collection = Datapimp::Sync.google.api.collections.first
                 #
                 # svg = collection.files.first
                 # svg.export_as_file(/download/path, "image/svg+xml")
                 Datapimp::Sync::GoogleDriveFolder.new(local: local, remote: remote)
               when options.type == "aws" || options.type == "s3"|| options.type == "amazon"
                 Datapimp::Sync::S3Bucket.new(local: local, remote: remote)
               end

      folder.run(action, options)
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
