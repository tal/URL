# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "url/version"

Gem::Specification.new do |s|
  s.name = %q{url}
  s.version = URL::VERSION

  s.authors = ["Tal Atlas"]
  s.date = %q{2011-07-25}
  s.description = %q{A simple url object to allow for OO based manipulation and usage of a url}
  s.email = %q{me@tal.by}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = Dir['lib/**/*.rb','LICENSE','spec/*','README.rdoc','Rakefile']
  s.homepage = %q{http://github.com/talby/url}
  s.require_paths = ["lib"]
  s.summary = %q{A URL object}
  s.add_development_dependency(%q<rspec>, ["~> 2"])
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<yard>, [">= 0.7.1"])
end

