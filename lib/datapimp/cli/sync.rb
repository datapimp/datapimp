command "sync folder" do |c|
  c.description = "Synchronize the contents of a local folder with a file sharing service"
  c.syntax = "datapimp sync folder [OPTIONS]"

  c.action do |args, options|

  end
end

command "sync data" do |c|
  c.description = "Synchronize the contents of a local data store with its remote source"
  c.syntax = "datapimp sync data [OPTIONS]"

  c.option '--type TYPE', String, "What type of source data is this? #{ Datapimp::Sync.data_source_types.join(", ") }"
  c.action do |args, options|

  end
end
