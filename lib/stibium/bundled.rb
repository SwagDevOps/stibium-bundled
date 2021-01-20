# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

unless Object.const_defined?(:Stibium)
  # Namespace
  module Stibium
  end
end

# Sample of use:
#
# ```ruby
# # file: lib/awesome_gem.rb
# module AwesomeGem
#   Stibium::Bundled.call(self, basedir: "#{__dir__}/..")
#
#   bundled&.tap do |bundle|
#     bundle.standalone! { require 'bundler/setup' if bundle.locked? }
#   end
# end
# ```
#
# or:
#
# ```ruby
# # file: lib/awesome_gem.rb
# module AwesomeGem
#   include(Stibium::Bundled)
#
#   self.bundled_from("#{__dir__}/..") do |bundle|
#     unless bundle.standalone!
#       require 'bundler/setup' if bundle.locked?
#     end
#   end
# end
# ```
#
# or simpler:
#
# ```ruby
# # file: lib/awesome_gem.rb
# module AwesomeGem
#   include(Stibium::Bundled)
#
#   self.bundled_from("#{__dir__}/..", setup: true)
# end
# ```
module Stibium::Bundled
  {
    Bundle: 'bundle',
    VERSION: 'version',
  }.each { |k, v| autoload(k, "#{__dir__}/bundled/#{v}") }

  class << self
    private

    # Callback invoked whenever the receiver is included in another module or class.
    #
    # @param [Class, Module] othermod
    #
    # @see https://ruby-doc.org/core-2.5.3/Module.html#method-i-included
    def included(othermod)
      othermod.singleton_class.__send__(:include, self) unless othermod.singleton_class?
    end
  end

  # Denote bundle is locked or standalone.
  #
  # @return [Boolean]
  #
  # @see .call
  def bundled?
    false
  end

  # @return [Bundle, nil]
  #
  # @see .call
  def bundled
    nil
  end

  protected

  # @param basedir [String, Pathname]
  # @param setup [Boolean]
  # @param env [Hash{String => String}]
  # @param ruby_config [Hash{Symbol => Object}]
  #
  # @return [Bundle. nil]
  def bundled_from(basedir, setup: false, env: ENV.to_h, ruby_config: {})
    Stibium::Bundled.call(self, basedir: basedir, env: env, ruby_config: ruby_config).bundled.tap do |bundle|
      unless bundle.nil?
        bundle.setup if setup.is_a?(TrueClass)

        yield(bundle) if block_given?
      end
    end
  end

  class << self
    # @param target [Class, Module]
    # @param basedir [String, Pathname]
    # @param env [Hash{String => String}]
    # @param ruby_config [Hash{Symbol => Object}]
    #
    # @return [Class, Module]
    def call(target, basedir:, env: ENV.to_h, ruby_config: {})
      target.tap do |t|
        t.singleton_class.tap do |sc|
          sc.singleton_class.__send__(:include, self)
          sc.define_method(:bundled?) { !bundled.nil? }
          sc.define_method(:bundled) do
            # @type [Bundle] bundle
            Bundle.new(basedir, env: env, ruby_config: ruby_config)
                  .yield_self { |bundle| bundle.bundled? ? bundle : nil }
          end
        end
      end
    end
  end
end
