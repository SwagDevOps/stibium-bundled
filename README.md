## Sample of use

```ruby
# file: lib/awesome_gem.rb

require 'stibium/bundled'

module AwesomeGem
  class << self
    include(Stibium::Bundled)
  end

  self.bundled_from("#{__dir__}/..") do |bundle|
    unless bundle.standalone!
      require 'bundler/setup' if bundle.locked?
    end
  end
end
```

## Install

```sh
bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
bundle install
```
