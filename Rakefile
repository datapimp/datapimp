Dir[File.join(Dir.pwd, 'tasks', '**', '*.rb')].each { |f| require f }
Dir[File.join(Dir.pwd, 'tasks', '*.rake')].each { |f| load f }

require "bundler/gem_tasks"

#Distribution.configure do |config|
#  config.package_name = 'datapimp'
#  config.version = Datapimp::VERSION
#  config.rb_version = '20150210-2.1.5'
#  config.packaging_dir = File.expand_path 'packaging'
#  config.native_extensions = [
#    'escape_utils-1.0.1',
#    'nokogiri-1.6.5',
#    'unf_ext-1.0.6'
#  ]
#end

task :default do
  puts "Sup?"
end
