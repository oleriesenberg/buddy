# -*- encoding: utf-8 -*-
require File.expand_path('../lib/buddy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ole Riesenberg"]
  gem.email         = ["or@oleriesenberg.com"]
  gem.description   = %q{Facebook library focusing on getting the work done.}
  gem.summary       = %q{Facebook library focusing on getting the work done.}
  gem.homepage      = "http://rubygems.org/gems/buddy"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "buddy"
  gem.require_paths = ["lib"]
  gem.version       = Buddy::VERSION

  gem.add_runtime_dependency "mini_fb", ">= 0.2.2"
  gem.add_runtime_dependency "yajl-ruby", ">= 0"
  gem.add_runtime_dependency "httparty", ">= 0"

  gem.add_development_dependency "rake"
end
