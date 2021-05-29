# frozen_string_literal: true

# test-related external dependencies and config
require "minitest/autorun"
require "minitest/reporters"
require "minitest/spec"
require "minitest/hooks/default"
require "minitest/focus"
require "minitest/fail_fast"
require "webmock/minitest"
require "spy"
require "minitest/tagz"
WebMock.enable_net_connect!
Minitest::Reporters.use!([Minitest::Reporters::ProgressReporter.new])


# bundle exec rake test TAGS=fast
# bundle exec rake test TAGS=slow
Minitest::Tagz.choose_tags(*ENV["TAGS"].split(",")) if ENV["TAGS"]

# local modules
ENV["USE_SIMENGINE"] = "true"
require "shipengine"
require "shipengine/exceptions"
require "test_utility/custom_assertions"
require "test_utility/factory"

# methods / constants that will be available globally
include CustomAssertions
include ShipEngine::Constants
