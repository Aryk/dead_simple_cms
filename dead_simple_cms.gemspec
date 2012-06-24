# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dead_simple_cms/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aryk Grosz"]
  gem.email         = ["aryk@mixbook.com"]
  gem.description   = %q{DeadSimpleCMS provides a way to define, modify, and present custom variables and content in your application}
  gem.summary       = %q{DeadSimpleCMS provides a way to define, modify, and present custom variables and content in your application}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dead_simple_cms"
  gem.require_paths = ["lib"]
  gem.version       = DeadSimpleCMS::VERSION

  gem.test_files = Dir["spec/**/*"]

  gem.add_dependency "activesupport", ">= 3.0"
  gem.add_dependency "activemodel",   ">= 3.0"

  gem.add_development_dependency "simple_form"
  gem.add_development_dependency "rails", ">= 3.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3"

end
