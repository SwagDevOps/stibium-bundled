# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../config'

# Config file reader.
class Stibium::Bundled::Bundle::Config::Reader
  autoload(:YAML, 'yaml')

  # @return [Hash{String => String}]
  attr_reader :env

  def initialize(env: ENV.to_h)
    self.tap do
      @env = env.dup.map { |k, v| [k.freeze, v.freeze] }.to_h.freeze
    end.freeze
  end

  # @return [Boolean]
  def ignore_config?
    env.key?('BUNDLE_IGNORE_CONFIG')
  end

  # Read given config file.
  #
  # @param file [Pathname]
  #
  # @return [Hash{String => Object}]
  def read(file)
    scrutinize(file).transform_values { |v| v.is_a?(String) ? YAML.safe_load(v) : v }
  end

  protected

  # @api private
  #
  # @param file [Pathname]
  #
  # @return [Hash{String => Object}]
  def scrutinize(file)
    return {} if ignore_config?

    return {} unless file.file? and file.readable?

    file.read.yield_self { |content| YAML.safe_load(content) }
  end
end
