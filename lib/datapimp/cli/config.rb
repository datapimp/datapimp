command 'config set' do |c|
  c.syntax = 'datapimp config set KEY=VALUE KEY=VALUE [options]'
  c.description = 'manipulate configuration settings'

  c.option '--global', 'Set the configuration globally'
  c.option '--local', 'Set the configuration globally'

  c.example "set a bunch of config parameters", "datapimp config set DROPBOX_APP_KEY=xxx DROPBOX_APP_SECRET=yyy GITHUB_APP_SECRET=zzz"

  c.action do |args, _options|
    Datapimp::Configuration.initialize!

    args.select { |pair| pair.match(/=/) }
      .map { |pair| pair.split('=') }
      .each do |group|
        key, value = group
        Datapimp.config.set(key, value, false, global: !!(_options.global))
      end

    Datapimp.config.save!

    Datapimp.config.show
  end
end
