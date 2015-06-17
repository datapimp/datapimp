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

  def self.sync_github_issues(options, args)
    client = Datapimp::Sync.github.api
    raise 'Must setup github client' unless client

    repo = args.shift
    raise 'Must supply a repository name' if repo.empty?

    issues = client.issues(repo, filter: "all")

    if options.output
      Pathname(options.output).open("w+") do |fh|
        fh.write(issues)
      end
    else
      puts issues.inspect
    end
  end

  def self.sync_github_issue_comments(options, args)
    client = Datapimp::Sync.github.api
    raise 'Must setup github client' unless client

    repo = args.shift
    raise 'Must supply a repository name' if repo.empty?

    issue = args.shift
    raise 'Must supply an issue ID' if issue.empty?

    issues = client.issue_comments(repo, issue)

    if options.output
      Pathname(options.output).open("w+") do |fh|
        fh.write(issues)
      end
    else
      puts issues.inspect
    end
  end
end
