command "sync folder" do |c|
  c.description = "Synchronize the contents of a local folder with a file sharing service"
  c.syntax = "datapimp sync folder LOCAL_PATH REMOTE_PATH [OPTIONS]"

  c.option '--type TYPE', String, "Which service is hosting the folder"
  c.option '--action ACTION', String, "Which sync action to run? push, pull"

  Datapimp::Cli.accepts_keys_for(c, :amazon, :google, :github, :dropbox)

  c.action do |args, options|
    options.default(action:"pull", type: "dropbox")

    local, remote = args

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
             when options.type == "aws" || options.type == "s3"
               Datapimp::Sync::S3Bucket.new(local: local, remote: remote)
             end

    folder.run(options.action, options.to_hash.to_mash)
  end
end

command "sync data" do |c|
  c.description = "Synchronize the contents of a local data store with its remote source"
  c.syntax = "datapimp sync data [OPTIONS]"

  c.option '--type TYPE', String, "What type of source data is this? #{ Datapimp::Sync.data_source_types.join(", ") }"
  c.option '--output FILE', String, "Write the output to a file"
  c.option '--columns NAMES', Array, "Extract only these columns"

  c.example "Syncing an excel file from dropbox ", "datapimp sync data --type dropbox --columns name,description --dropbox-app-key ABC --dropbox-app-secret DEF --dropbox-client-token HIJ --dropbox-client-secret JKL spreadsheets/test.xslx"
  c.example "Syncing a google spreadsheet", "datapimp sync data --type google-spreadsheet WHATEVER_THE_KEY_IS"

  Datapimp::Cli.accepts_keys_for(c, :google, :github, :dropbox)

  c.action do |args, options|
    if options.type == "google-spreadsheet"
      Datapimp::DataSync.sync_google_spreadsheet(options, args)
    end
  end
end
