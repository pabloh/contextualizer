# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "contextualizer/version"

Gem::Specification.new do |spec|
  spec.name          = "contextualizer"
  spec.version       = Contextualizer::VERSION
  spec.authors       = ["Pablo Herrero"]
  spec.email         = ["pablodherrero@gmail.com"]

  spec.summary       = %q{Allows to define context values for your objects}
  spec.description   = %q{Allows to define context values for your objects}
  spec.homepage      = "http://github.com/pabloh/contextualizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency "ruby2_keywords"

  spec.add_development_dependency "bundler", ">= 1.14.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
