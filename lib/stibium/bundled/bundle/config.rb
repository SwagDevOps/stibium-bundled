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
#
# 1. Local config (``.bundle/config`` or ``$BUNDLE_APP_CONFIG/config``)
# 2. Environmental variables (``ENV``)
# 3. Global config (``~/.bundle/config``)
# 4. Bundler default config - PARTIAL support is implemented in ``Config.defaults``
#
# @see https://bundler.io/v2.2/bundle_config.html
# @see https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development
# @see .load
# @see .read
# @see .env
# @see .defaults
class Stibium::Bundled::Bundle::Config < ::Hash
  autoload(:Pathname, 'pathname')

  # @param basedir [String, Pathname]
  # @param env [Hash{String => String}]
  def initialize(basedir, env: ENV.to_h.dup)
    super().tap do
      @env = self.class.__send__(:env, source: env).freeze
      @file = Pathname.new(basedir).yield_self { |path| self.resolve_file(path) }

      self.class.__send__(:load, self.file, env: env).each { |k, v| self[k.freeze] = v.freeze }
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

  # Resolve path to local config (depending on ``BUNDLE_APP_CONFIG`` value).
  #
  # @param basedir [Pathname]
  #
  # @return [Pathname]
  def resolve_file(basedir)
    self.env.fetch('BUNDLE_APP_CONFIG', '.bundle').yield_self { |s| Pathname.new(s) }.yield_self do |path|
      (path.absolute? ? path : basedir.join(path)).join('config')
    end
  end

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
    # @see https://bundler.io/v2.2/bundle_config.html
    #
    # @return [Hash{String => Object}]
    def load(file, env: ENV.to_h.dup)
      # @formatter:off
      self.defaults                                # 4. Bundler default config
          .merge(self.global_config(env: env.dup)) # 3. Global config
          .merge(self.env(source: env.dup))        # 2. Environmental variables
          .merge(self.read(file))                  # 1. Local config
          .sort.to_h
      # @formatter:on
    end

    # Get global config.
    #
    # @api private
    #
    # @param env [Hash{String => String}]
    #
    # @return [Hash{String => Object}]
    def global_config(env: ENV.to_h.dup)
      env['HOME'].yield_self do |home_path|
        return {} if home_path.nil?

        Pathname.new(home_path).expand_path.join('.bundle/config').yield_self do |file|
          self.read(file)
        end
      end
    end

    # Get bundler related environment variables (``/^BUNDLE_.+/``)
    #
    # @param source [Hash{String => String}]
    #
    # @api private
    #
    # @return [Hash{String => Object}]
    def env(source: ENV.to_h.dup)
      source.dup.keep_if { |k, _| /^BUNDLE_.+/ =~ k }
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
