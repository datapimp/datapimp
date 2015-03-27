command "sync folder" do |c|
  c.description = "Synchronize the contents of a local folder with a file sharing service"
  c.syntax = "datapimp sync folder LOCAL_PATH REMOTE_PATH [OPTIONS]"

  c.option '--type TYPE', String, "Which service is hosting the folder"

  Datapimp::Cli.accepts_keys_for(c, :amazon, :google, :github, :dropbox)

  c.action do |args, options|

  end
end

command "sync data" do |c|
  c.description = "Synchronize the contents of a local data store with its remote source"
  c.syntax = "datapimp sync data [OPTIONS]"

  c.option '--type TYPE', String, "What type of source data is this? #{ Datapimp::Sync.data_source_types.join(", ") }"
  c.option '--output FILE', String, "Write the output to a file"
  c.option '--columns NAMES', Array, "Extract only these columns"

  c.example "Syncing an excel file from dropbox ", "datapimp sync data --type dropbox --columns name,description --dropbox-app-key ABC --dropbox-app-secret DEF --dropbox-client-token HIJ --dropbox-client-secret JKL spreadsheets/test.xslx"

  Datapimp::Cli.accepts_keys_for(c, :google, :github, :dropbox)

  c.action do |args, options|

  end
end
