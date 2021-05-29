# frozen_string_literal: true

require "test_helper"
require "shipengine"

describe "Smoke tests" do
  it "Should test a version number" do
    refute_nil ::ShipEngine::VERSION
  end
end
