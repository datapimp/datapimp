command 'view amazon setup' do |c|
  c.syntax = 'datapimp view amazon setup'
  c.description = 'view the amazon (s3 + cloudfront) setup'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.action do |args, options|
    bucket = Datapimp::Sync::S3Bucket.new(remote: args.first)
    cloudfront = bucket.cloudfront
    require 'terminal-table'

    rows = []
    rows << ["Bucket Name", bucket.remote]
    rows << ["Website Hostname", bucket.website_hostname]
    rows << ["Website URL", bucket.website_url]
    rows << ["Cloudfront Hostname", cloudfront.domain]
    rows << ["Cloudfront ID", cloudfront.id]
    rows << ["Cloudfront Domains", cloudfront.cname && cloudfront.cname.join(",")]

    table = Terminal::Table.new :rows => rows, :headings => %w(Setting Value)

    puts table
  end
end


