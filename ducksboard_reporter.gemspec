# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ducksboard_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "ducksboard_reporter"
  spec.version       = DucksboardReporter::VERSION
  spec.authors       = ["unnu"]
  spec.email         = ["norman.timmler@gmail.com"]
  spec.summary       = %q{Report values to ducksboard}
  spec.description   = %q{Report values to ducksboard}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "ducksboard"
  spec.add_runtime_dependency "hashie"
  spec.add_runtime_dependency "celluloid"
  spec.add_runtime_dependency "timers"
  spec.add_runtime_dependency "trollop"
  spec.add_runtime_dependency "rb-inotify"
end
