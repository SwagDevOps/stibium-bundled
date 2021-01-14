# rubocop:disable all
require 'rbconfig'
ruby_engine = RUBY_ENGINE
ruby_version = RbConfig::CONFIG["ruby_version"]
path = File.expand_path('..', __FILE__)
$:.unshift File.expand_path("#{path}/../#{ruby_engine}/#{ruby_version}/lib")
