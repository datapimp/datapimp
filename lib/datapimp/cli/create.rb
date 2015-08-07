command 'create cache invalidations' do |c|
  c.syntax = "#{$datapimp_cli} create cache invalidations"
  c.description = 'invalidate remote cache layers (i.e. cloudfront after a s3 deploy)'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--all-html', 'Invalidate all HTML paths in the bucket'
  c.option '--verbose', 'Print extra information such as exactly what paths get invalidated'
  c.option '--previous-deploy', 'Invalidate all paths from the previous deploy'
  c.option '--paths PATHS', Array, 'List the specific paths you would like to invalidate'
  c.option '--local-path FOLDER', String, 'Determine which paths to invalidate by looking at the files in this folder'
  c.option '--ignore-paths PATTERN', String, 'Ignore any paths matching the supplied regex'
  c.option '--match-paths PATTERN', String, 'Only invalidate paths matching the supplied regex'

  c.action do |args, options|
    options.defaults(:paths => [])

    bucket = Datapimp::Sync::S3Bucket.new(remote: args.first)

    paths = Array(options.paths)

    if options.local_path
      local = Pathname(options.local_path)

      paths += Dir[local.join('**/*')].map do |file|
        file = Pathname(file)
        "/#{file.relative_path_from(local)}"
      end
    end

    if options.local_path.to_s.length == 0 && options.all_html
      html_files = bucket.s3.files.select {|file| file.key.match(/\.html/) }

      paths += html_files.map {|file| file.public_url }.map do |url|
        path = URI.parse(url).path.gsub("/#{bucket.remote}","")
        index = path.gsub('/index.html','')
        index = "/" if index == ""
        [path, index]
      end
    end

    if options.local_path.to_s.length > 0 && options.all_html
      paths.select! {|path| path.match(/\.html$/) }
      paths.map! {|path| [path, path.gsub('/index.html','')] }
      paths.flatten!
      paths << "/"
    end

    paths.flatten!

    # TODO
    # Need to pull out paths that were previous deployed.
    # We can rely on the s3 bucket deploy manifest for this.
    if options.previous_deploy
      items = bucket.deploy_manifest["uploaded"]
      items
    end

    if options.match_paths
      paths.select! {|path| path.to_s.match(options.ignore_paths) }
    end

    if options.ignore_paths
      paths.reject! {|path| path.to_s.match(options.ignore_paths) }
    end

    paths.reject! {|path| path.length == 0}

    if paths.length > 0
      log "Posting invalidations for #{ paths.length } paths"
      Datapimp::Sync.amazon.cdn.post_invalidation(bucket.cloudfront.id, paths)
      log "\nInvalidated paths: #{ paths.inspect }" if options.verbose
    end
  end
end

command 'create s3 bucket' do |c|
  c.syntax = "#{$datapimp_cli} create s3 bucket BUCKETNAME"
  c.description = 'create an s3 bucket to use for website hosting'

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--setup-website', 'Setup the bucket for website hosting'
  c.option '--create-redirect-bucket', 'Setup a redirect bucket'
  c.option '--private', nil, 'Make this bucket private.'

  c.action do |args, options|
    raise 'Must specify bucket name' unless args.first
    Datapimp::Sync::S3Bucket.new(remote: args.first, redirect: !!(options.create_redirect_bucket), setup_website: !!(options.setup_website)).run_create_action(make_private: !!options.private)
  end
end

command 'create cloudfront distribution' do |c|
  c.syntax = "#{$datapimp_cli} create cloudfront distribution"
  c.description = "create a cloudfront distribution to link to a specific bucket"

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--bucket NAME', String, 'The name of the bucket that will provide the content'
  c.option '--domains DOMAINS', Array, 'What domains will be pointing to this bucket?'

  c.action do |args, options|
    options.default(bucket: args.first)

    bucket = Datapimp::Sync::S3Bucket.new(remote: options.bucket)

    cdn_options = {
      enabled: true,
      custom_origin: {
        'DNSName'=> bucket.website_hostname,
        'OriginProtocolPolicy'=>'http-only'
      },
      comment: options.bucket,
      caller_reference: Time.now.to_i.to_s,
      cname: Array(options.domains),
      default_root_object: 'index.html'
    }

    distributions = Datapimp::Sync.amazon.cdn.distributions

    distribution_id = distributions.find {|d| d.comment == options.bucket }.try(:id)

    if !distribution_id
      distribution = Datapimp::Sync.amazon.cdn.distributions.create(cdn_options)
    elsif distribution_id
      distribution = distributions.get(distribution_id)
      distribution.etag = distribution.etag
      distribution.cname = Array(options.domains)
      distribution.save
    end

  end
end

# bin/datapimp create cf protected distribution --name z-test --bucket 'warbler.architects.io' --error-bucket z-test-error-bucket --domains hola.com,hello.com --app-url blueprints.architects.io --origin-access-identity E2RCKW2LSUD589 --trace
command 'create cf protected distribution' do |c|
  c.syntax = "datapimp create cf protected distribution"
  c.description = "create a cloudfront PROTECTED distribution using signed cookies"

  Datapimp::Cli.accepts_keys_for(c, :amazon)

  c.option '--name NAME', String, 'The name for this distribution'
  c.option '--bucket NAME', String, 'The name of the *new* bucket that will provide the content'
  c.option '--error-bucket NAME', String, 'The name of the *new* bucket that will hold the errors folder and 403.html file'
  c.option '--domains DOMAINS', Array, 'What domains will be pointing to this bucket?'
  c.option '--app-url NAME', String, 'The url of the AUTH Applitacion'
  c.option '--origin-access-identity NAME', String, 'The Origin Access Identity to be used to create the distribution'

  c.action do |args, options|
    cf = Datapimp::Sync.amazon.cloud_formation

    template_body = File.read(File.join(File.dirname(__FILE__), '..', 'templates/cloudfront', 'aws_cloudfront_distribution_template.json'))

    res = cf.create_stack(
      stack_name: options.name,
      template_body: template_body,
      parameters: [
        {
          parameter_key: "AppLocation",
          parameter_value: URI.parse(options.app_url).host,
          use_previous_value: true
        },
        {
          parameter_key: "BucketName",
          parameter_value: options.bucket,
          use_previous_value: true
        },
        {
          parameter_key: "ErrorBucketName",
          parameter_value: options.error_bucket,
          use_previous_value: true
        },
        {
          parameter_key: "DistributionComment",
          parameter_value: "#{options.name} distribution",
          use_previous_value: true
        },
        {
          parameter_key: "OriginAccessIdentity",
          parameter_value: options.origin_access_identity,
          use_previous_value: true
        }
      ]
    )

    begin
      puts "Waiting for stack creation process to finish ..."
      sleep 30
      stack = cf.describe_stacks(stack_name: options.name).stacks.first
    end while stack.stack_status == "CREATE_IN_PROGRESS"

    if stack.stack_status != "CREATE_COMPLETE"
      puts "stack failed to create"
      exit 1
    end

    s3 = Aws::S3::Client.new(region: cf.config.region)
    template_body_403 = ERB.new(File.read(File.join(File.dirname(__FILE__), '../templates/cloudfront', '403.html.erb'))).result(binding)

    # S3 403.html error file
    s3.put_object(
      bucket:         options.error_bucket,
      key:            'errors/403.html',
      content_type:   'text/html',
      cache_control:  'max-age=300',
      acl:            'public-read',
      body:           template_body_403
    )
  end
end
