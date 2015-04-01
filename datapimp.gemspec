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
  spec.homepage      = "https://github.com/datapimp/datapimp"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  spec.add_dependency 'pry', '~> 0.10'
  spec.add_dependency 'hashie', '~> 2.0.5'
  spec.add_dependency 'commander', '~> 4.3'
  spec.add_dependency 'fog-aws', '~> 0.1'
  spec.add_dependency 'dropbox-api', '0.4.5'
  spec.add_dependency 'google_drive', '~> 1.0'
  spec.add_dependency 'google-api-client', '~> 0.7'
  spec.add_dependency 'rack-contrib', '~> 1.2'
  spec.add_dependency 'uri_template', '~> 0.7'
  spec.add_dependency 'dnsimple-ruby', '~> 1.7'
  spec.add_dependency 'rack-proxy', '~> 0.5'
  spec.add_dependency 'axlsx', '~> 2.0'
  spec.add_dependency 'launchy', '~> 2.4'
  spec.add_dependency 'oauth', '~> 0.4'
  spec.add_dependency 'octokit', '~> 3.0'
  spec.add_dependency 'activesupport', '~> 4.0'
  spec.add_dependency 'github-fs', '~> 0'

  # these are locked to specific versions so that 
  # we can use the native extensions for traveling ruby
  spec.add_dependency 'nokogiri', '1.6.5'
  spec.add_dependency 'unf', '0.1.4'
  spec.add_dependency 'unf_ext', '0.0.6'
  
  spec.add_development_dependency "rake", '~> 0'
  spec.add_development_dependency "rack-test", '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.require_paths = ["lib"]

end
