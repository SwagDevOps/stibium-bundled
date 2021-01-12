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

  # @return [Pathname]
  attr_reader :path

  # @param path [String, Pathname]
  #
  # @raise [Errno::ENOENT]
  # @raise [ArgumentError] when given ``path`` is not a directory.
  def initialize(path)
    self.tap do
      @path = Pathname.new(path).realpath.freeze

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
    !!standalone_setupfile&.file?
  end

  # Load standalone setup if present
  #
  # @return [Boolean]
  def standalone!
    # noinspection RubyResolve
    standalone?.tap { |b| require standalone_setupfile if b }
  end

  protected

  # @see #standalone?
  #
  # @return [Pathname, nil]
  def standalone_setupfile
    standalone_setupfiles.last
  end

  # @api privare
  #
  # @return [Array<Pathname>]
  def standalone_setupfiles
    Dir.glob("#{path}/**/bundler/setup.rb").map { |fp| Pathname.new(fp) }.keep_if do |file|
      lambda do
        return false unless file.file? and file.readable?

        file.read.yield_self do |content|
          content =~ /.*=\s*RUBY_ENGINE/ and content =~ /^\$:.unshift/
        end
      end.call
    end.sort_by { |file| file.lstat.mtime }
  end
end
