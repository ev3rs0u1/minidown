# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minidown/version'

Gem::Specification.new do |spec|
  spec.name          = "minidown"
  spec.version       = Minidown::VERSION
  spec.authors       = ["jjy"]
  spec.email         = ["jjyruby@gmail.com"]
  spec.description   = %q{Minidown is a lightweight & fast markdown parser, with complete GFM support.}
  spec.summary       = %q{Minidown is a lightweight & fast markdown parser, with complete GFM support.}
  spec.homepage      = "https://github.com/ev3rs0u1/minidown"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
