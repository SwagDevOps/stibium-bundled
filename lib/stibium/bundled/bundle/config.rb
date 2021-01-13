# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../bundle'

# Describe bundler configuration settings.
#
# Bundler loads configuration settings in this order:
# 1. Local config (``.bundle/config`` or ``$BUNDLE_APP_CONFIG/config``)
# 2. Environmental variables (``ENV``)
# 3. Global config (``~/.bundle/config``) - WILL NOT be supported
# 4. Bundler default config - PARTIAL support is implemented in ``Config.defaults``
#
# @see https://bundler.io/v2.2/bundle_config.html
# @see https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
# @see .load
# @see .read
# @see .env
# @see .defaults
#
# @todo Add support for ``BUNDLE_APP_CONFIG`` env variable
class Stibium::Bundled::Bundle::Config < ::Hash
  # @param basedir [String, Pathname]
  # @param filepath [String]
  def initialize(basedir, filepath: '.bundle/config', env: ENV.to_h.dup)
    super().tap do
      @file = Pathname.new(basedir).join(filepath || '').expand_path.freeze
      @env = self.class.__send__(:env, source: env).freeze

      self.class.__send__(:load, self.file, env: self.env).each { |k, v| self[k.freeze] = v.freeze }
    end.freeze
  end

  # @return [String]
  def to_path
    file.to_path
  end

  # @return [Boolean]
  def exist?
    file.exist?
  end

  # @return [Boolean]
  def file?
    file.file?
  end

  # @return [Boolean]
  def readable?
    file.readable?
  end

  # @return [Hash{String => Object}]
  attr_reader :env

  protected

  # @return [Pathname]
  attr_reader :file

  class << self
    autoload(:Pathname, 'pathname')
    autoload(:YAML, 'yaml')

    # Default config values (as seen from an empty environment).
    #
    # ```shell
    # rm -rfv ~/.bundle/config .bundle/config
    # env -i $(which bundle) install --standalone
    # cat .bundle/config
    # ```
    #
    # @see Stibium::Bundled::Bundle#bundler_setup
    def defaults
      {
        'BUNDLE_PATH' => 'bundle',
      }
    end

    protected

    # Load config.
    #
    # @param file [Pathname]
    # @param env [Hash{String => String}]
    #
    # @api private
    #
    # @return [Hash{String => Object}]
    def load(file, env: ENV.to_h.dup)
      self.read(file).yield_self { |result| self.env(source: env.dup).merge(self.defaults).merge(result) }.sort.to_h
    end

    # @param source [Hash{String => String}]
    #
    # @api private
    #
    # @return [Hash{String => Object}]
    def env(source: ENV.to_h.dup)
      source.keep_if { |k, _| /^BUNDLE_/ =~ k }
            .transform_keys(&:freeze)
            .transform_values { |v| (v.is_a?(String) ? YAML.safe_load(v) : v).freeze }
            .sort.to_h
    end

    # Read given config file.
    #
    # @api private
    #
    # @param file [Pathname]
    #
    # @return [Hash{String => Object}]
    def read(file)
      return {} unless file.file? and file.readable?

      (file.read.yield_self { |content| YAML.safe_load(content) })
        .transform_values { |v| v.is_a?(String) ? YAML.safe_load(v) : v }
    end
  end
end
