# frozen_string_literal: true

# ```sh
# bundle config set --local clean 'true'
# bundle config set --local path 'vendor/bundle'
# bundle install
# ```
source 'https://rubygems.org'
git_source(:github) { |name| "https://github.com/#{name}.git" }

group :default do
end

group :development do
  { github: 'SwagDevOps/kamaze-project', branch: 'develop' }.tap do |options|
    gem(*['kamaze-project'].concat([options]))
  end

  gem 'listen', '~> 3.1'
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.0'
  gem 'rugged', '~> 1.0'
  gem 'sys-proc', '~> 1.1', '>= 1.1.2'
  # repl ------------------------------------------------------------
  gem 'interesting_methods', '~> 0.1'
  gem 'pry', '~> 0.12'
  # version --------------------------------------------------------
  gem 'kamaze-version', '~> 1.0'
end

group :doc do
  gem 'github-markup', '~> 3.0'
  gem 'redcarpet', '~> 3.4'
  gem 'yard', '~> 0.9'
end

group :test do
  gem 'rspec', '~> 3.8'
  gem 'simplecov', '~> 0.16'
end
