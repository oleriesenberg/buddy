# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{buddy}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ole Riesenberg"]
  s.date = %q{2010-04-12}
  s.description = %q{buddybrand's facebook library}
  s.email = %q{labs@buddybrand.de}
  s.files = [
    "lib/buddy.rb",
     "lib/buddy/rails/backwards_compatible_param_checks.rb",
     "lib/buddy/rails/controller.rb",
     "lib/buddy/rails/controller_extensions.rb",
     "lib/buddy/rails/url_helper.rb",
     "lib/buddy/railtie.rb",
     "lib/buddy/service.rb",
     "lib/buddy/session.rb",
     "lib/buddy/user.rb",
     "lib/rack/facebook.rb",
     "test/test_buddy.rb"
  ]
  s.homepage = %q{http://buddybrand.de}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{buddybrand's facebook library}
  s.test_files = [
    "test/test_buddy.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mini_fb>, [">= 0.2.2"])
    else
      s.add_dependency(%q<mini_fb>, [">= 0.2.2"])
    end
  else
    s.add_dependency(%q<mini_fb>, [">= 0.2.2"])
  end
end

