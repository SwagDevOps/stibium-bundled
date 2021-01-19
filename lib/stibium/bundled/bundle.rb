# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../bundled'

# Describe a bundle.
class Stibium::Bundled::Bundle
  autoload(:Pathname, 'pathname')
  {
    Config: 'config',
  }.each { |k, v| autoload(k, "#{__dir__}/bundle/#{v}") }

  # @return [Pathname]
  attr_reader :path

  # @return [Config]
  attr_reader :config

  # @param path [String, Pathname]
  #
  # @raise [Errno::ENOENT]
  # @raise [ArgumentError] when given ``path`` is not a directory.
  def initialize(path, env: ENV.to_h)
    self.tap do
      @path = Pathname.new(path).realpath.freeze
      @config = Config.new(self.path, env: env).freeze

      raise ArgumentError, 'path is not a directory' unless self.path.directory?
    end.freeze
  end

  # @return [String]
  def to_path
    path.to_path
  end

  # Denote lockfile (``gems.locked`` or ``Gemfile.lock``) is present.
  #
  # @see #gemfiles
  #
  # @return [Boolean]
  def locked?
    !!gemfiles&.fetch(1, nil)
  end

  # Denote bundle seems installed by bundler.
  #
  # @return [Boolean]
  def bundled?
    locked? or standalone?
  end

  # Get path to gemfile.
  #
  # @see #gemfiles
  #
  # @return [Pathname, nil]
  def gemfile
    gemfiles&.fetch(0, nil)
  end

  # Get gemfile files (gemfile + lockfile) or nothing.
  #
  # @note Files are returned in pairs, gemfile and its lockfile. As a result a missing file provides empty result.
  #
  # @return [Array<Pathname>, nil]
  def gemfiles
    [%w[gems.rb gems.locked], %w[Gemfile Gemfile.lock]].map do |m|
      m.map { |fname| path.join(fname) }.keep_if(&:file?)
    end.reject(&:empty?).reject { |r| r.size < 2 }.first
  end

  # Denote bundle seems to be installed as a standalone.
  #
  # @see https://bundler.io/man/bundle-install.1.html
  #
  # @return [Boolean]
  def standalone?
    !!bundler_setup
  end

  # Load standalone setup if present.
  #
  # @return [self]
  # @raise [Errno::ENOENT, TypeError]
  def standalone!(&fallback)
    self.tap do
      # noinspection RubyResolve
      require bundler_setup&.realpath
    rescue Errno::ENOENT, TypeError => e
      fallback ? fallback.call(self) : raise(e)
    end
  end

  # Load standalone setup if present, else fallback to ``bundler/setup`` when locked.
  #
  # @return [self]
  #
  # @raise [LoadError]
  #
  # @see https://bundler.io/v1.5/bundler_setup.html
  # @see https://github.com/ruby/ruby/blob/0e40cc9b194a5e46024d32b85a61e651372a65cb/lib/bundler.rb#L139
  # @see https://github.com/ruby/ruby/blob/0e40cc9b194a5e46024d32b85a61e651372a65cb/lib/bundler/setup.rb
  # @see https://github.com/ruby/ruby/blob/69ed64949b0c02d4b195809fa104ff23dd100093/lib/bundler.rb#L11
  # @see https://github.com/ruby/ruby/blob/69ed64949b0c02d4b195809fa104ff23dd100093/lib/bundler/rubygems_integration.rb
  def setup
    self.standalone! { require 'bundler/setup' if self.locked? }.yield_self { self }
  end

  protected

  # Standalone setup file.
  #
  # ``bundle install --standalone[=<list>]`` makes a bundle that can work without depending on
  # Rubygems or Bundler at runtime.
  # A space separated list of groups to install has to be specified.
  # Bundler creates a directory named ``bundle`` and installs the bundle there.
  # It also generates a ``bundle/bundler/setup.rb`` file to replace Bundler's own setup in the manner required.
  #
  # @see #standalone?
  # @see #standalone!
  # @see https://bundler.io/v2.2/man/bundle-install.1.html#OPTIONS
  #
  # @return [Pathname, nil]
  def bundler_setup
    Pathname.new(config.fetch('BUNDLE_PATH')).yield_self do |bundle_path|
      (bundle_path.absolute? ? bundle_path : path.join(bundle_path)).join('bundler/setup.rb').yield_self do |file|
        (file.file? and file.readable?) ? file : nil # rubocop:disable Style/TernaryParentheses
      end
    end
  end
end
