# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "buddy/version"

Gem::Specification.new do |s|
  s.name        = "buddy"
  s.version     = Buddy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ole Riesenberg"]
  s.email       = ["or@buddybrand.com"]
  s.homepage    = "http://rubygems.org/gems/buddy"
  s.summary     = %q{buddybrand's facebook library}
  s.description = %q{buddybrand's facebook library}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  Gem::Specification.new do |s|
    s.add_dependency(%q<mini_fb>, [">= 0.2.2"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<httparty>, [">= 0"])
  end
end
