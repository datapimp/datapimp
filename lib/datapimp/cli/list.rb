command "list spreadsheets" do |c|
  c.syntax = "datapimp list spreadsheets"
  c.description = "list the spreadsheets which can be used as datasources"

  c.option '--type TYPE', String, "What type of source data is this? #{ Datapimp::Sync.data_source_types.join(", ") }"

  Datapimp::Cli.accepts_keys_for(c, :google, :dropbox)

  c.action do |args, options|
    Datapimp::Sync.google.spreadsheets.each do |sheet|
      puts "#{ sheet.key }\t\t#{ sheet.title }"
    end
  end
end

