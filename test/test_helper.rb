# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'
require 'minitest/hooks/default'
require 'webmock/minitest'
require 'color_pound_spec_reporter'
WebMock.enable_net_connect!

Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]
require 'minitest/fail_fast'
ENV['USE_SIMENGINE'] = 'true'
require 'test_utility/custom_assertions'

include CustomAssertions # rubocop:disable Style/MixinUsage
