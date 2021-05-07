# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
