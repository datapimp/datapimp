command "sync folder" do |c|
  c.description = "Synchronize the contents of a local folder with a file sharing service"
  c.syntax = "datapimp sync folder LOCAL_PATH REMOTE_PATH [OPTIONS]"

  c.option '--type TYPE', String, "Which service is hosting the folder"
  c.option '--action ACTION', String, "Which sync action to run? push, pull"
  c.option '--reset', nil, "Reset the local path (if supported by the syncable folder)"

  Datapimp::Cli.accepts_keys_for(c, :amazon, :google, :github, :dropbox)

  c.action do |args, options|
    options.default(action:"pull", type: "dropbox", reset: false)
    local, remote = args
    Datapimp::Sync.dispatch_sync_folder_action(local, remote, options.to_hash)
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
    if options.type == "google-spreadsheet" || options.type == "google"
      Datapimp::DataSync.sync_google_spreadsheet(options, args)
    elsif options.type == "github-issues"
      repository  = args.shift

      service = Datapimp::DataSync::Github.new(repository, options)
      service.sync_issues
    elsif options.type == "github-issue-comments"
      repository  = args.shift
      issue       = args.shift

      service = Datapimp::DataSync::Github.new(repository, options)
      service.sync_issue_comments(issue)
    end
  end
end
