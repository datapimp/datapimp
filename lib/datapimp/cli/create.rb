command 'create cache invalidations' do |c|
  c.syntax = 'datapimp create cache invalidations'
  c.description = 'invalidate remote cache layers (i.e. cloudfront after a s3 deploy)'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--all-html', 'Invalidate all HTML paths in the bucket'
  c.option '--previous-deploy', 'Invalidate all paths from the previous deploy'
  c.option '--paths PATHS', Array, 'The paths you would like to invalidate'

  c.action do |args, options|
    options.defaults(:paths => [])

    bucket = Datapimp::Sync::S3Bucket.new(remote: args.first)

    paths = Array(options.paths)

    if options.all_html
      html_files = bucket.s3.files.select {|file| file.key.match(/\.html/) }

      paths += html_files.map {|file| file.public_url }.map do |url|
        path = URI.parse(url).path.gsub("/#{bucket.remote}","")
        index = path.gsub('/index.html','')
        index = "/" if index == ""
        [path, index]
      end

      paths.flatten!
    end

    if options.previous_deploy
      items = bucket.deploy_manifest["uploaded"]
      binding.pry
    end

    if paths.length > 0
      log "Posting invalidations for #{ paths.length } paths"
      Datapimp::Sync.amazon.cdn.post_invalidation(bucket.cloudfront.id, paths)
      log "Invalidated paths: #{ paths.inspect }"
    end
  end
end

command 'create s3 bucket' do |c|
  c.syntax = 'datapimp create s3 bucket BUCKETNAME'
  c.description = 'create an s3 bucket to use for website hosting'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--setup-website', 'Setup the bucket for website hosting'
  c.option '--create-redirect-bucket', 'Setup a redirect bucket'

  c.action do |args, options|
    raise 'Must specify bucket name' unless args.first
    Datapimp::Sync::S3Bucket.new(remote: args.first, redirect: !!(options.create_redirect_bucket), setup_website: !!(options.setup_website)).run_create_action()
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
