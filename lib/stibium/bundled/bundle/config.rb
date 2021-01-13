# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../bundle'

# Describe a bundle config.
class Stibium::Bundled::Bundle::Config < ::Hash
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  # @param basedir [String, Pathname]
  # @param filepath [String]
  def initialize(basedir, filepath: '.bundle/config')
    super().tap do
      @file = Pathname.new(basedir).join(filepath || '').expand_path.freeze

      self.class.__send__(:read, file)
          .yield_self { |result| self.class.defaults.merge(result) }
          .sort
          .each { |k, v| self[k.freeze] = v.freeze }
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

  protected

  # @return [Pathname]
  attr_reader :file

  class << self
    # Default config values (as seen from an empty environment).
    #
    # ```shell
    # rm -rfv ~/.bundle/config .bundle/config
    # bundle install --standalone
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
