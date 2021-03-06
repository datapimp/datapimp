command "list spreadsheets" do |c|
  c.syntax = "#{$datapimp_cli} list spreadsheets"
  c.description = "list the spreadsheets which can be used as datasources"

  c.option '--type TYPE', String, "What type of source data is this? #{ Datapimp::Sync.data_source_types.join(", ") }"
  c.option '--filter PATTERN', String, "Filter the titles by the specified pattern"

  Datapimp::Cli.accepts_keys_for(c, :google, :dropbox)

  c.action do |args, options|
    puts "\nKey / Argument\t\tTitle"
    puts "============\t\t==========="
    lines = Datapimp::Sync.google.spreadsheets.map do |sheet|
      "#{ sheet.key }\t\t#{ sheet.title }"
    end

    lines = lines.grep(/#{options.filter}/) if options.filter.to_s.length > 0

    lines.each {|l| puts(l) }

    if lines.length > 0
      puts "\n\nExample:"
      puts "====="
      puts "#{$datapimp_cli} sync data #{ lines.first.split(/\t/).first } --type google-spreadsheet"
      puts "\n\n"
    end
  end
end

command "list folders" do |c|
  c.syntax= "#{$datapimp_cli} list folders [OPTIONS]"
  c.description= "lists folders in a remote service"

  c.option '--type SERVICE', String, 'Which service to search: dropbox, google, amazon'
  c.option '--filter PATTERN', nil, 'Filter the results matching PATTERN'

  c.action do |args, options|
    type = options.type.to_sym

    case
    when type == :dropbox
      puts "Path\n===\n"
      Datapimp::Sync.dropbox.ls(*([options.filter].compact)).each do |entry|
        puts entry.path if entry.is_dir
      end
    when type == :google
      puts "Collection\n====\n"
      Datapimp::Sync.google.api.collections.each do |collection|
        puts collection.title
      end
    when type == :amazon
      puts "Bucket\n====\n"
      Datapimp::Sync.amazon.storage.directories.each do |dir|
        puts dir.key
      end
    end
  end
end
