require 'rubygems'
require 'rake'
require 'rake/testtask'

desc 'Default: run tests.'
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "buddy"
    s.summary = "buddybrand's facebook library"
    s.email = "labs@buddybrand.de"
    s.homepage = "http://buddybrand.de"
    s.description = "buddybrand's facebook library"
    s.authors = ["Ole Riesenberg"]
    s.files = FileList["{lib,test}/**/*.rb"]
    s.add_dependency "mini_fb", ">= 0.2.2"
    s.add_dependency "yajl-ruby"
    s.add_dependency "httparty"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    #t.options = ['--any', '--extra', '--opts'] # optional
  end
rescue LoadError
end
