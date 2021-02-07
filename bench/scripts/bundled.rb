# frozen_string_literal: true

require_relative '../../lib/stibium-bundled'
require 'stibium/bundled'

"#{__dir__}/../..".tap do |basedir|
  Class.new do
    include(Stibium::Bundled).bundled_from(basedir, setup: true)
  end
end
