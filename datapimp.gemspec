# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datapimp/version'

Gem::Specification.new do |spec|
  spec.name          = "datapimp"
  spec.version       = Datapimp::VERSION
  spec.authors       = ["Jonathan Soeder"]
  spec.email         = ["jonathan.soeder@gmail.com"]
  spec.description   = %q{Write a gem description}
  spec.summary       = %q{Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"
  
  spec.add_dependency "mutations"
  spec.add_dependency "rails"

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
  spec.add_development_dependency 'aws-sdk'
  spec.add_development_dependency 'typhoeus'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  spec.require_paths = ["lib"]
end
