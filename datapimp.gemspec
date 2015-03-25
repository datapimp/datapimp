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

  spec.require_paths = ["lib"]
end
