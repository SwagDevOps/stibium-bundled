# frozen_string_literal: true

require 'stibium/bundled'
require 'kamaze/project'

# noinspection RubyLiteralArrayInspection
[
  'cs:correct', 'cs:control', 'cs:pre-commit',
  'doc', 'doc:watch',
  'gem', 'gem:install', 'gem:compile', 'gem:push',
  'misc:gitignore',
  'shell', 'sources:license', 'test', 'version:edit',
].yield_self do |tasks|
  Kamaze.project do |project|
    project.subject = Stibium::Bundled
    project.name = 'stibium-bundled'
    project.tasks = tasks
  end.load!
end
