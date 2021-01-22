# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../bundle'

# Describe vendor directory.
class Stibium::Bundled::Bundle::Directory
  autoload(:RbConfig, 'rbconfig')
  autoload(:Pathname, 'pathname')

  # @return [Pathname]
  attr_reader :path

  # @param path [String, Pathname]
  # @param ruby_config [Hash{Symbol => Object}]
  def initialize(path, ruby_config: {})
    @path = Pathname.new(path).expand_path.freeze
    @ruby_config = {
      engine: RUBY_ENGINE,
      version: RbConfig::CONFIG['ruby_version'],
    }.merge(ruby_config.to_h)
  end

  # @return [String]
  def to_path
    path.to_path
  end

  alias to_s to_path

  # @return [Array<Pathname>]
  def specifications
    [ruby_config.fetch(:engine), ruby_config.fetch(:version), 'specifications', '*.gemspec'].yield_self do |parts|
      self.path.join(*parts).yield_self do |s|
        Dir.glob(s).sort.map { |fp| Pathname.new(fp) }.keep_if(&:file?)
      end
    end
  end

  protected

  # @return [Hash{Symbol => Object}]
  attr_reader :ruby_config
end
