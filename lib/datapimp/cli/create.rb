command 'create s3 bucket' do |c|
  c.syntax = 'datapimp create s3 bucket BUCKETNAME'
  c.description = 'create an s3 bucket to use for website hosting'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.action do |args, options|
    raise 'Must specify bucket name' unless args.first
    Datapimp::Sync::S3Bucket.new(remote: args.first).run_create_action()
  end
end

command 'create cloudfront distribution' do |c|
  c.syntax = "datapimp create cloudfront distribution"
  c.description = "create a cloudfront distribution to link to a specific bucket"

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--bucket NAME', String, 'The name of the bucket that will provide the content'
  c.option '--domains DOMAINS', Array, 'What domains will be pointing to this bucket?'

  c.action do |args, options|
    bucket = Datapimp::Sync::S3Bucket.new(remote: options.bucket)

    cdn_options = {
      enabled: true,
      custom_origin: {
        'DNSName'=> bucket.website_hostname,
        'OriginProtocolPolicy'=>'http-only'
      },
      comment: options.bucket,
      caller_reference: Time.now.to_i.to_s,
      cname: Array(options.domains).join(","),
      default_root_object: 'index.html'
    }

    distributions = Datapimp::Sync.amazon.cdn.distributions

    distribution = distributions.find {|d| d.comment == options.bucket }

    if !distribution
      distribution = Datapimp::Sync.amazon.cdn.distributions.create(cdn_options)
    end

    log "Cloudfront distribution created: #{ distribution.domain } status: #{ distribution.status }"
  end
end
