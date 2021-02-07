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

# main ----------------------------------------------------------------
require_relative 'lib/stibium-bundled'

%w[lib tasks].each do |dir|
  Dir.glob("#{__dir__}/rake/#{dir}/*.rb").sort.each { |fp| require fp }
end

task default: [:gem]

# @type [Kamaze::Project] project
if project.path('spec').directory?
  task :spec do |_task, args|
    Rake::Task[:test].invoke(*args.to_a)
  end
end
