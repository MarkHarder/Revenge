# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'revenge/version'

Gem::Specification.new do |spec|
  spec.name          = "revenge"
  spec.version       = Revenge::VERSION
  spec.authors       = ["Mark Harder", "Stephen Quenzer"]
  spec.email         = ["mark.harder899@gmail.com"]
  spec.summary       = ["A 2D platformer game in the style of Commander Keen."]
  spec.description   = ["Using ruby and Gosu, this game brings back a lot of the features of the popular Commander Keen series with some changes."]
  spec.homepage      = ""
  spec.license       = "Artistic License"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "Gosu"
end
