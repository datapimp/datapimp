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
  c.option '--view NAME', String, "Which view should we display?"
  c.option '--format FORMAT', String, "Which format to serialize the output in? valid options are JSON"
  c.option '--columns NAMES', Array, "Extract only these columns"
  c.option '--relations NAMES', Array, "Also fetch these relationships on the object if applicable"

  c.option '--limit LIMIT', Integer, "Limit the number of results for Pivotal resources"
  c.option '--offset OFFSET', Integer, "Offset applied when using the limit option for Pivotal resources"

  c.example "Syncing an excel file from dropbox ", "datapimp sync data --type dropbox --columns name,description --dropbox-app-key ABC --dropbox-app-secret DEF --dropbox-client-token HIJ --dropbox-client-secret JKL spreadsheets/test.xslx"
  c.example "Syncing a google spreadsheet", "datapimp sync data --type google-spreadsheet WHATEVER_THE_KEY_IS"
  c.example "Syncing Pivotal Tracker data, user activity", "datapimp sync data --type pivotal --view user-activity"
  c.example "Syncing Pivotal Tracker data, project activity", "datapimp sync data --type pivotal --view project-activity PROJECT_ID"
  c.example "Syncing Pivotal Tracker data, project stories", "datapimp sync data --type pivotal --view project-stories PROJECT_ID"
  c.example "Syncing Pivotal Tracker data, project story notes", "datapimp sync data --type pivotal --view project-story-notes PROJECT_ID STORY_ID"
  c.example "Syncing keen.io data, extraction from an event_collection", "datapimp sync data --type keen EVENT_COLLECTION"
  c.example "Syncing Github Issues", "datapimp sync data --type github --view issues REPOSITORY"
  c.example "Syncing Github Issue Comments", "datapimp sync data --type github --view issue-comments REPOSITORY ISSUE_ID"

  Datapimp::Cli.accepts_keys_for(c, :google, :github, :dropbox)

  c.action do |args, options|
    options.default(view:"to_s")

    data = Datapimp::Sync.dispatch_sync_data_action(args, options.to_hash)

    result = data.send(options.view)
    result = JSON.generate(result) if options.format == "json" && options.type != "google-spreadsheet"

    if options.output
      Pathname(options.output).open("w+") {|fh| fh.write(result) }
    else
      puts result
    end
  end
end
