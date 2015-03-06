# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'es_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'es_client'
  spec.version       = EsClient::VERSION
  spec.authors       = ['Alex Leschenko']
  spec.email         = ['leschenko.al@gmail.com']
  spec.summary       = 'Simple and robust elasticsearch client'
  spec.description   = 'This elasticsearch client is just all you need to search and index your data with persistent http connection'
  spec.homepage      = 'https://github.com/leschenko/es_client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'activemodel'
  spec.add_development_dependency 'ruby-progressbar'

  spec.add_dependency 'excon'
  spec.add_dependency 'activesupport'
end
