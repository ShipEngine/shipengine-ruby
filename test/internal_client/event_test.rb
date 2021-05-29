# frozen_string_literal: true

require "test_helper"

include ShipEngine::Subscriber
describe "EventEmitter" do
  it "responds to events" do
    methods = EventEmitter.instance_methods
    assert_includes(methods, :on_request_sent)
    assert_includes(methods, :on_response_received)
    assert_includes(methods, :on_error)
  end
end
