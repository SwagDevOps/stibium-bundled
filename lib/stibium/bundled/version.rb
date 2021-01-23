# frozen_string_literal: true

# Copyright (C) 2020-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../bundled'

Stibium::Bundled.instance_eval do
  autoload(:YAML, 'yaml')
  autoload(:Pathname, 'pathname')

  Pathname.new(__dir__).join('version.yml').tap do |file|
    YAML.safe_load(file.read).yield_self do |v|
      %w[major minor patch].map { |key| v.fetch(key) }.join('.')
    end.tap do |version|
      lambda do
        require 'kamaze/version'
      rescue LoadError
        version
      else
        Kamaze::Version.new.freeze
      end.tap { |func| self.const_set(:VERSION, func.call) }
    end
  end
end
