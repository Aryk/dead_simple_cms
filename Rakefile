#!/usr/bin/env rake
require "bundler/gem_tasks"

# RSpec 2.0
require 'rspec/core/rake_task'

desc 'Default: run specs'
task :default => :spec
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('rcov') do |t|
  t.pattern   = "spec/**/*_spec.rb"
  t.rcov      = true
  t.rcov_opts = ['--exclude', 'spec']
end
