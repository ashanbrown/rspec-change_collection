# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/change_collection/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-change_collection"
  spec.version       = RSpec::ChangeCollection::VERSION
  spec.authors       = ["Andrew S. Brown"]
  spec.email         = ["andrew@dontfidget.com"]
  spec.description   = %q{RSpec extension gem for attribute matching}
  spec.summary       = %q{Provides "change_collection" method formally part of rspec-core}
  spec.homepage      = "https://github.com/dontfidget/rspec-change_collection"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rspec-core', '>= 2.99.0.beta1'
  spec.add_runtime_dependency 'rspec-expectations', '>= 2.99.0.beta1'
  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'rake',     '~> 10.1.0'

end
