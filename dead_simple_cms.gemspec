# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dead_simple_cms/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aryk Grosz"]
  gem.email         = ["aryk@mixbook.com"]
  gem.summary       = %q{DeadSimpleCMS provides a way to define, modify, and present custom variables and content in your application.}
  gem.homepage      = "http://github.com/Aryk/dead_simple_cms"

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

  s.description = <<-description
Dead Simple CMS is a library for modifying different parts of your website without the overhead of having a
fullblown CMS. The idea with this library is simple: provide an easy way to hook into different parts of your
application (not only views) by defining the different parts to modify in an easy, straight-forward DSL.

The basic components of this library include:

 * A DSL to define the changeable values in your app
 * Form generators based on SimpleForm (with or without Bootstrap) and default rails FormBuilder
 * Expandable storage mechanisms so you can store the data in different locations
   * Currently supported: Redis, Database, Memcache, even Memory (for testing)
 * Presenters/renderers so you can take groups of variables and render them into your views (ie image_tag)

What it doesn't have:

 * Versioning - be able to look at old versions of the content
 * Timing - set start and end time for different content
 * Page builder tools - this is not the right tool if you want to design full pages
  description

end
