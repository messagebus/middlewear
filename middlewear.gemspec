# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middlewear/version'

Gem::Specification.new do |spec|
  spec.name          = 'middlewear'
  spec.version       = Middlewear::VERSION
  spec.authors       = ['Eric Saxby', 'Matt Camuto']
  spec.email         = ['sax@livinginthepast.org']

  spec.summary       = %q{Generic middleware registry and runner}
  spec.description   = %q{Generic middleware registry and runner}
  spec.homepage      = 'https://github.com/messagebus/middlewear'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
