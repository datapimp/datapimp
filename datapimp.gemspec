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

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  spec.add_dependency 'pry'
  spec.add_dependency 'hashie', '< 3.0'
  spec.add_dependency 'colored'
  spec.add_dependency 'commander'
  spec.add_dependency 'fog-aws'
  spec.add_dependency 'dropbox-api', '>= 0.4.6'
  spec.add_dependency 'google_drive'
  spec.add_dependency 'rack-contrib'
  spec.add_dependency 'uri_template'
  spec.add_dependency 'dnsimple-ruby'
  spec.add_dependency 'rack-proxy'
  spec.add_dependency 'axlsx'
  spec.add_dependency 'launchy'
  spec.add_dependency 'oauth', '~> 0.4.7'
  spec.add_dependency 'octokit', '>= 3.0.0'
  spec.add_dependency 'activesupport', '>= 4.0.0'
  spec.add_dependency 'nokogiri', '1.6.5'
  spec.add_dependency 'github-fs'
  
  spec.add_development_dependency "rake", '~> 0'
  spec.add_development_dependency "rack-test", '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency "pry-nav", '~> 0'

  spec.require_paths = ["lib"]

end
