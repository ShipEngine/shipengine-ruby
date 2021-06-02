# frozen_string_literal: true

require "test_helper"

include ShipEngine::Emitter
describe "EventEmitter" do
  it "responds to events" do
    methods = EventEmitter.instance_methods
    assert_includes(methods, :on_request_sent)
    assert_includes(methods, :on_response_received)
    assert_includes(methods, :on_error)
  end
end

describe "request/response events" do
  # DX-1490
  tag :simengine
  it "should dispatch an on_request_sent event" do
    timeout = 666000
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)
    client = ShipEngine::Client.new(api_key: "abc123", retries: 0, timeout: timeout, emitter: emitter)
    client.validate_address(Factory.valid_address_params)
    request_sent_event, _ = get_dispatched_events(on_request_sent)
    assert_request_sent_event({
      message: "Calling the ShipEngine address.validate.v1 API at https://simengine.herokuapp.com/jsonrpc",
      status_code: 200,
      retry_attempt: 0,
      timeout: timeout,
    }, request_sent_event)

    headers = request_sent_event.headers
    assert_equal("abc123", fuzzy_get_header("API-Key", headers))
    assert_content_type_json(request_sent_event.headers)
  end

  it "should dispatch an on_request_sent once" do
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)

    client = ShipEngine::Client.new(api_key: "abc123", emitter: emitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    response = client.validate_address(Factory.valid_address_params)
    assert response
    assert_called(1, on_request_sent)

    event_1, _ = get_dispatched_events(on_request_sent)

    assert_request_sent_event({ retry_attempt: 0 }, event_1)
    assert_kind_of(Hash, event_1.body)
    assert_kind_of(Hash, event_1.body.dig("params", "address"), "on_request_sent should be passed the body (as a hash)")

    assert_equal(
      "Calling the ShipEngine address.validate.v1 API at https://simengine.herokuapp.com/jsonrpc",
      event_1.message,
      "should have a message"
    )
  end

  tag :simengine
  # DX-1493 - SDKs | Ruby | Config | Tests | Response received event (error)
  it "should dispatch an on_response_received event and an on_request_received event" do
    timeout = 666000
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_response_received = Spy.on(emitter, :on_response_received)
    client = ShipEngine::Client.new(api_key: "abc123", retries: 0, timeout: timeout, emitter: emitter)
    assert_raises_rate_limit_error do
      client.validate_address(Factory.rate_limit_address_params)
    end
    response_received_event, _ = get_dispatched_events(on_response_received)
    assert_response_received_event({
      message: "Received an HTTP 429 response from the ShipEngine address.validate.v1 API",
      status_code: 429,
      timeout: timeout,
      retry_attempt: 0,
    }, response_received_event)
    assert_between(0, 3, response_received_event.elapsed)
    assert_content_type_json(response_received_event.headers)
  end
end
