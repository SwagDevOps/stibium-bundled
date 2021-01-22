# frozen_string_literal: true

require 'sys/proc'

Sys::Proc.progname = nil

# coverage ------------------------------------------------------------
if Gem::Specification.find_all_by_name('simplecov').any?
  autoload(:YAML, 'yaml')
  autoload(:SimpleCov, 'simplecov')

  if YAML.safe_load(ENV['coverage'].to_s) == true
    SimpleCov.start do
      add_filter 'rake/'
      add_filter 'spec/'
    end
  end
end

# project -------------------------------------------------------------
require_relative 'lib/stibium-bundled'
require 'stibium/bundled'
require 'kamaze/project'

Kamaze.project do |project|
  project.subject = Stibium::Bundled
  project.name    = 'stibium-bundled'
  # noinspection RubyLiteralArrayInspection
  project.tasks   = [
    'cs:correct', 'cs:control', 'cs:pre-commit',
    'doc', 'doc:watch',
    'gem', 'gem:install', 'gem:compile',
    'misc:gitignore',
    'shell', 'sources:license', 'test', 'version:edit',
  ]
end.load!

task default: [:gem]

if project.path('spec').directory?
  task :spec do |_task, args|
    Rake::Task[:test].invoke(*args.to_a)
  end
end
