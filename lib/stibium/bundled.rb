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
#     unless bundle.standalone!
#         require 'bundler/setup' if bundle.locked?
#     end
#   end
# end
# ```
#
# or:
#
# ```ruby
# # file: lib/awesome_gem.rb
# module AwesomeGem
#   class << self
#     include(Stibium::Bundled)
#   end
#
#   self.bundled_from("#{__dir__}/..") do |bundle|
#     unless bundle.standalone!
#       require 'bundler/setup' if bundle.locked?
#     end
#   end
# end
# ```
module Stibium::Bundled
  {
    Bundle: 'bundle',
    VERSION: 'version',
  }.each { |k, v| autoload(k, "#{__dir__}/bundled/#{v}") }

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

  # @param [String, Pathname] basedir
  #
  # @return [Bundle. nil]
  def bundled_from(basedir)
    Stibium::Bundled
      .call(self, basedir: basedir)
      .bundled
      .tap { |bundle| yield(bundle) if block_given? and bundle }
  end

  class << self
    # @param target [Class, Module]
    # @param basedir [String, Pathname]
    #
    # @return [Class, Module]
    def call(target, basedir:)
      target.tap do |t|
        t.singleton_class.tap do |sc|
          sc.singleton_class.__send__(:include, self)
          sc.define_method(:bundled?) { !bundled.nil? }
          sc.define_method(:bundled) do
            # @type [Bundle] bundle
            # rubocop:disable Style/TernaryParentheses
            Bundle.new(basedir).yield_self { |bundle| (bundle.locked? or bundle.standalone?) ? bundle : nil }
            # rubocop:enable Style/TernaryParentheses
          end
        end
      end
    end
  end
end
