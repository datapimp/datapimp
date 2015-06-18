module Datapimp::DataSync
  def self.sync_google_spreadsheet(options, *args)
    require 'google_drive' unless defined?(::GoogleDrive)

    raise 'Must setup google client' unless Datapimp::Sync.google.spreadsheets

    key = args.shift
    name = args.shift || "Spreadsheet"

    raise 'Must supply a spreadsheet key' unless key

    spreadsheet = Datapimp::Sources::GoogleSpreadsheet.new(name, key: key)

    if options.output
      Pathname(options.output).open("w+") do |fh|
        fh.write(spreadsheet.to_s)
      end
    else
      puts spreadsheet.to_s
    end
  end
end
