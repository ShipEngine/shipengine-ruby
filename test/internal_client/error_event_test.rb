# frozen_string_literal: true

require "test_helper"

describe "Error event" do
  subject do
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_error_spy = Spy.on(emitter, :on_error)

    client = ShipEngine::Client.new("abc123", emitter: emitter)

    assert_raises ::ShipEngine::Exceptions::ShipEngineError do
      client.validate_address(Factory.invalid_address_params)
    end

    on_error_spy
  end

  it "should have one call" do
    assert_equal(1, subject.calls.count)
  end

  # DX-1494
  it "should have the correct shape" do
    event, _ = get_dispatched_events(subject)
    start_time = Time.now
    assert_error_event({
      error_code: ::ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED),
      message: "Invalid address. At least one address line is required.",
      error_type: ::ShipEngine::Exceptions::ErrorType.get(:VALIDATION),
    }, event)
    assert_nil(event.request_id)
    assert_within_secs_from_now(2, start_time)
  end
end
