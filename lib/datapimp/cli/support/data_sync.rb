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

  class Github
    attr_reader :options, :repository

    def initialize(repository, options)
      @repository = repository
      @options    = options
    end

    def sync_issues
      issues = client.issues(repository, filter: "all")
      serve_output(issues)
    end

    def sync_issue_comments(issue_id)
      comments = client.issue_comments(repository, issue_id)
      serve_output(comments)
    end

    private

    def client
      @_client ||= Datapimp::Sync.github.api
    end

    def serve_output(output)
      if @options.output
        Pathname(options.output).open("w+") do |f|
          f.write(output)
        end
      else
        puts output.inspect
      end
    end
  end
end
