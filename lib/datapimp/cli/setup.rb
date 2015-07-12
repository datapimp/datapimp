command "setup google" do |c|
  c.syntax = "#{$datapimp_cli} set up google"
  c.description = "setup integration with google drive"

  c.action do |args, options|
    Datapimp::Sync.google.setup()
  end
end

command "setup amazon" do |c|
  c.syntax = "#{$datapimp_cli} setup amazon"
  c.description = "setup integration with amazon"

  c.action do |args, options|
    Datapimp::Sync.amazon.interactive_setup()
  end
end

command "setup dropbox" do |c|
  c.syntax = "#{$datapimp_cli} set up dropbox"
  c.description = "setup integration with dropbox"

  c.action do |args, options|
    Datapimp::Sync.dropbox.setup()
  end
end

command "setup github" do |c|
  c.syntax = "#{$datapimp_cli} set up github"
  c.description = "setup integration with github"

  c.action do |args, options|
    Datapimp::Sync.github.setup()
  end
end

command "setup pivotal" do |c|
  c.syntax = "#{$datapimp_cli} set up github"
  c.description = "setup integration with github"

  c.action do |args, options|
    Datapimp::Sync.pivotal.setup()
  end
end
