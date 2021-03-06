require 'rspec'
require 'webmock/rspec'
require 'vcr'

require 'datapimp'

ENV['TESTING'] = "1"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module Datapimp
  def self.spec_root
    Pathname(File.dirname(__FILE__))
  end

  def self.dummy_path
    spec_root.join("dummy")
  end

  def self.fixtures_path
    spec_root.join("support","fixtures")
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into :webmock
end
