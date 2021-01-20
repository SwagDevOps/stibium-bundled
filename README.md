# ``stibium-bundled`` [![Gem Version](https://badge.fury.io/rb/stibium-bundled.svg)][rubygems:stibium-bundled]

This gem is intended to mimic Bundler's behavior 
and conform to [bundler configuration options][bundler:config]. 

``stibium-bundled`` detects ``gems.rb`` and ``gems.locked`` 
(or ``Gemfile`` and ``Gemfile.lock``)
and [``bundler/setup``][bundler:setup] (for [standalone][man:install#options] installation).

``standalone`` makes a bundle that can work __without depending__ on 
Rubygems or Bundler at runtime. 
Bundler generates a ``bundler/setup.rb`` file 
to replace Bundler's own setup in the manner required.

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

  self.bundle("#{__dir__}/..") do |bundle|
    bundle.standalone! { require 'bundler/setup' if bundle.locked? }
  end
end
```

or even more simple:

```ruby
# file: lib/awesome_gem.rb

require 'stibium/bundled'

module AwesomeGem
  include(Stibium::Bundled)

  self.bundled_from("#{__dir__}/..", setup: true)
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
