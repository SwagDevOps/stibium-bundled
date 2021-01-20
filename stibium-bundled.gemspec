# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

Gem::Specification.new do |s|
  s.name        = "stibium-bundled"
  s.version     = "0.0.2"
  s.date        = "2021-01-11"
  s.summary     = "Denote bundle state"
  s.description = "Denote bundle state, based on conventions."

  s.licenses    = ["GPL-3.0"]
  s.authors     = ["Dimitri Arrigoni"]
  s.email       = "dimitri@arrigoni.me"
  s.homepage    = "https://github.com/SwagDevOps/stibium-bundled"

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  # requires version >= 2.5.0 due to yield_self
  s.required_ruby_version = ">= 2.5.0"
  s.require_paths = ["lib"]

  s.files = [
    ".yardopts",
    "README.md",
    "lib/stibium-bundled.rb",
    "lib/stibium/bundled.rb",
    "lib/stibium/bundled/bundle.rb",
    "lib/stibium/bundled/bundle/config.rb",
    "lib/stibium/bundled/bundle/directory.rb",
    "lib/stibium/bundled/version.rb",
    "lib/stibium/bundled/version.yml",
  ]

  s.add_runtime_dependency("kamaze-version", ["~> 1.0"])
end

# Local Variables:
# mode: ruby
# End:
