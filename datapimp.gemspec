# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datapimp/version'

Gem::Specification.new do |spec|
  spec.name          = "datapimp"
  spec.version       = Datapimp::VERSION
  spec.authors       = ["Jonathan Soeder"]
  spec.email         = ["jonathan.soeder@gmail.com"]
  spec.description   = %q{Your rails app in a custom tailored suit.}
  spec.summary       = %q{A collection of API development patterns that I have accumulated in my career as a boss.}
  spec.homepage      = ""
  spec.license       = "MIT"
  
  spec.add_dependency "mutations"
  spec.add_dependency "hashie"
  spec.add_dependency "rails"
  spec.add_dependency 'redis'
  spec.add_dependency 'redis-objects'
  spec.add_dependency 'colored'
  spec.add_dependency 'commander'
  spec.add_dependency 'active_model_serializers'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'machinist'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'jbuilder'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  spec.require_paths = ["lib"]
end
