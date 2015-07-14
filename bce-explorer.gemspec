# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bce_explorer/version'

Gem::Specification.new do |spec|
  spec.name          = 'bce-explorer'
  spec.version       = BceExplorer::VERSION
  spec.summary       = 'Block Chain Explorer for altcoins.'
  spec.description   = <<-EOF
     Block Chain Explorer for altcoins.
     Extracted from BCE project.
     Works as an application for one coin project
    EOF

  spec.author        = 'Mad Zebra'
  spec.email         = 'dunno'
  spec.homepage      = 'https://github.com/madzebra/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(/spec/)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'
  spec.add_runtime_dependency 'bundler', '~> 1.7'
  spec.add_runtime_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'sinatra', '~> 1.4.5'
  spec.add_runtime_dependency 'haml'
  spec.add_runtime_dependency 'mongo'
  spec.add_runtime_dependency 'bson_ext'
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'bce-client'
end
