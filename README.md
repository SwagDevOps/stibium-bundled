# ``stibium-bundled`` [![Gem Version](https://badge.fury.io/rb/stibium-bundled.svg)][rubygems:stibium-bundled] [![Maintainability](https://api.codeclimate.com/v1/badges/7121242b44c7a3cc4f61/maintainability)](https://codeclimate.com/github/SwagDevOps/stibium-bundled/maintainability)

This gem is intended to mimic Bundler's behavior and conform to [bundler configuration options][bundler:config].

``stibium-bundled`` detects ``gems.rb`` and ``gems.locked``
(or ``Gemfile`` and ``Gemfile.lock``)
and [``bundler/setup``][bundler:setup] (for [standalone][man:install#options] installation).

``standalone`` makes a bundle that can work __without depending__ on Bundler (or Rubygems) at runtime. Bundler generates
a ``bundler/setup.rb`` file to replace Bundler's own setup in the manner required.

[Configuration settings][bundler:config] are loaded in this order:

1. Local config (``.bundle/config`` or ``"$BUNDLE_APP_CONFIG/config``)
2. Environment variables (``ENV``)
3. Global config (``~/.bundle/config``)
4. Default config

## Sample of use

```ruby
# file: lib/awesome_gem.rb

require 'stibium/bundled'

module AwesomeGem
  include(Stibium::Bundled)

  self.bundled_from("#{__dir__}/..", setup: true)
end
```

or more concise:

```ruby
# file: lib/awesome_gem.rb

require 'stibium/bundled'

module AwesomeGem
  include(Stibium::Bundled).bundled_from("#{__dir__}/..", setup: true)
end
```

or load a gem depending on status:

```ruby
# file: lib/awesome_gem.rb

require 'stibium/bundled'

module AwesomeGem
  include(Stibium::Bundled).bundled_from("#{__dir__}/..", setup: true) do |bundle|
    if Object.const_defined?(:Gem) and bundle.locked? and bundle.installed?
      'foo-bar'.tap do |gem_name|
        unless bundle.specifications.keep_if { |spec| spec.name == gem_name }.empty?
          require gem_name.gsub('-', '/')
        end
      end
    end
  end
end
```

## Install

```sh
bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
bundle install --standalone
```

<!-- hyperlinks -->

[rubygems:stibium-bundled]: https://rubygems.org/gems/stibium-bundled
[bundler:config]: https://bundler.io/v2.2/bundle_config.html
[bundler:setup]: https://bundler.io/v1.5/bundler_setup.html
[man:install#options]: https://bundler.io/man/bundle-install.1.html#OPTIONS
