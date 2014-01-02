ENV['RAILS_ENV'] ||= 'test'

require 'active_model'
require 'datapimp'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'machinist/active_record'
require 'sham'
require 'faker'
require 'rack/test'
require "pry"

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Sham.define do
  email     { Faker::Internet.email }
  name     { Faker::Name.name }
  salary   {|index| 30000 + (index * 1000)}
  key1 { Faker::Name.name }
  key2 { Faker::Name.name }
  key3 { Faker::Name.name }

end

RSpec.configure do |config|
  config.before(:suite) do
    Models.make
  end

  config.before(:all)   { Sham.reset(:before_all) }
  config.before(:each)  { Sham.reset(:before_each) }
end

