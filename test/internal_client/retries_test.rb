# frozen_string_literal: true

require "test_helper"

describe "retries" do
  after do
    WebMock.reset!
  end
  it "Should throw an error if retries is invalid at instantiation or at method call" do
    retries_err = { message: "Retries must be zero or greater.", code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

    stub = stub_request(:post, SIMENGINE_URL)
      .with(body: /.*/)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    # configuration during insantiation
    assert_raises_shipengine_validation(retries_err) do
      ShipEngine::Client.new(api_key: "abc1234", retries: -1)
    end

    # config during instantiation and method call
    assert_raises_shipengine_validation(retries_err) do
      client = ShipEngine::Client.new(api_key: "abc1234")
      client.configuration.retries = -1
      client.validate_address(Factory.valid_address_params)
    end

    # config during method call
    assert_raises_shipengine_validation(retries_err) do
      client = ShipEngine::Client.new(api_key: "abc1234")
      client.validate_address(Factory.valid_address_params, { retries: -1 })
    end

    assert_not_requested(stub)

    ShipEngine::Client.new(api_key: "abc1234", retries: 5) # valid
    ShipEngine::Client.new(api_key: "abc1234", retries: 0) # valid
  end

  it "Should not throw an error if retries is valid" do
    stub_request(:post, SIMENGINE_URL)
      .with(body: /.*/)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    client = ShipEngine::Client.new(api_key: "abc1234")
    client.configuration.retries = 2
    client.validate_address(Factory.valid_address_params)
    client.configuration.retries = 0
    client.validate_address(Factory.valid_address_params)
  end

  it "should have a default value of 1" do
    client = ShipEngine::Client.new(api_key: "abc1234")
    assert_equal(1, client.configuration.retries)
  end

  it "should retry once again on a 429 (default)" do
    stub = stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 200, body: Factory.valid_address_res_json)

    client = ShipEngine::Client.new(api_key: "abc123", retries: 2)
    response = client.validate_address(Factory.valid_address_params)
    assert(response.valid?)
    assert_requested(stub, times: 3)
  end

  it "should stop retrying if retries is exhausted (and return rate limit error)" do
    client = ShipEngine::Client.new(api_key: "abc123", retries: 2)
    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)

    assert_raises_rate_limit_error { client.validate_address(Factory.valid_address_params) }
  end

  it "should throw an error with the number of tries" do
    client = ShipEngine::Client.new(api_key: "abc123", retries: 2)
    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)
    assert_raises_rate_limit_error(retries: 2) { client.validate_address(Factory.valid_address_params) }
  end

  it "respects the Retry-After header, which can override error.retryAfter" do
    client = ShipEngine::Client.new(api_key: "abc123", retries: 1)
    stub = stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error, headers: { "Retry-After": 1 })
      .then.to_return(status: 200, body: Factory.valid_address_res_json)
    start = Time.now
    client.validate_address(Factory.valid_address_params)
    diff = Time.now - start

    assert_operator(diff, :>, 1, "should take more than than 1 second")
    assert_requested(stub, times: 2)
  end

  # Can I use: https://auctane.atlassian.net/browse/DX-1497

  it "should not make any additional retries if retries is disabled (i.e. set to 0)" do
    client = ShipEngine::Client.new(api_key: "abc123", retries: 0)
    stub = stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 200, body: Factory.valid_address_res_json)
    assert_raises_rate_limit_error { client.validate_address(Factory.valid_address_params) }
    assert_requested(stub, times: 1)
  end

  it "should dispatch an on_request_sent three times (once to start and twice more for every retry)" do
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)

    client = ShipEngine::Client.new(api_key: "abc123", retries: 2, emitter: emitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)
    assert_raises_rate_limit_error(retries: 2) { client.validate_address(Factory.valid_address_params) }

    assert_called(3, on_request_sent)

    event_1, event_2, event_3 = get_dispatched_events(on_request_sent)
    assert_request_sent_event({
      retry_attempt: 0,
      message: "Calling the ShipEngine address.validate.v1 API at https://simengine.herokuapp.com/jsonrpc",
    }, event_1)
    assert_equal(Factory.valid_address_params[:street], event_1.body.dig("params", "address", "street"))

    assert_request_sent_event({
      retry_attempt: 1,
    }, event_2)

    assert_request_sent_event({
      retry_attempt: 2,
    }, event_3)
  end

  it "should dispatch an on_response_received three times (once to start and twice more for every retry)" do
    class MyEventEmitter < ShipEngine::Emitter::EventEmitter
      def on_response_received(event); end
    end

    emitter = MyEventEmitter.new
    on_response_received = Spy.on(emitter, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", retries: 2, emitter: emitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)

    assert_raises_rate_limit_error(retries: 2) { client.validate_address(Factory.valid_address_params) }

    assert_called(3, on_response_received)

    event_1, event_2, event_3 = get_dispatched_events(on_response_received)

    # Event 1
    timestamp_diff = Time.now - event_1.datetime
    assert_equal(true, timestamp_diff > 0 && timestamp_diff < 1, "timestamp_d should be less than a second from now")
    assert_kind_of(Hash, event_1.body)

    assert_response_received_event({
      retry_attempt: 0,
      message: "Received an HTTP 429 response from the ShipEngine address.validate.v1 API",
      status_code: 429,
    }, event_1)

    # Event 2 (retry_attempt 1)
    assert_response_received_event({
      retry_attempt: 1,
    }, event_2)

    # Event 3 (retry_attempt 2)
    assert_response_received_event({
      retry_attempt: 2,
    }, event_3)
  end


  it "should make requests immediately if retryAfter is set to 0" do
    retries = 2
    client = ShipEngine::Client.new(api_key: "abc123", retries: retries)
    stub = stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error(data: { retryAfter: 0 })).then
      .to_return(status: 429, body: Factory.rate_limit_error(data: { retryAfter: 0 })).then
      .to_return(status: 200, body: Factory.valid_address_res_json)
    start = Time.now
    client.validate_address(Factory.valid_address_params)
    diff = Time.now - start
    assert_operator(diff, :<, 1, "should take less than 1 second")
    assert_requested(stub, times: retries + 1)
  end

  # DX-1497
  it "^ similar test, but uses simengine to complete the AC in DX-1497 (make requests immediately if retryAfter is set to 0)" do
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)
    on_response_received = Spy.on(emitter, :on_response_received)
    client = ShipEngine::Client.new(api_key: "abc123", retries: 0, emitter: emitter)
    client.validate_address(Factory.valid_address_params)

    assert_called(1, on_request_sent)
    assert_called(1, on_response_received)

    request_sent_event, _ = get_dispatched_events(on_request_sent)
    response_received_event, _ = get_dispatched_events(on_response_received)
    assert_raises_rate_limit_error(retries: 0) do
      client.validate_address(Factory.rate_limit_address_params)
    end
    assert_request_sent_event({ retry_attempt: 0 }, request_sent_event)
    assert_response_received_event({ retry_attempt: 0 }, response_received_event)
  end

  # DX-1500
  it "Functional test: Should retry 1 time after waiting 3 seconds" do
    class MyEventEmitter < ShipEngine::Emitter::EventEmitter
      def on_request_sent(event); end

      def on_response_received(event); end
    end

    emitter = MyEventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)
    on_response_received = Spy.on(emitter, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", emitter: emitter)

    start = Time.now
    assert_raises_rate_limit_error { client.validate_address({ street: ["429 Rate Limit Error"], postal_code: "78751", country: "US" }) }
    diff = Time.now - start
    assert(diff > 3 && diff < 4, "should take between 3 and 4 seconds. Took #{diff} seconds.")
    assert_called(2, on_request_sent)
    assert_called(2, on_response_received)

    event1, event2 = get_dispatched_events(on_request_sent)
    event_1_time = event1.datetime
    event_2_time = event2.datetime
    diff = event_2_time - event_1_time
    assert_operator(diff, :>=, 3, "the timestamps of each event should be at least 3 seconds apart. Diff: #{diff} seconds")
  end

  tag :slow
  it "Should retry 3 times, waiting 1 second on each retry" do
    retries = 3
    client = ShipEngine::Client.new(api_key: "abc123", retries: retries)
    stub = stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error(data: { retryAfter: 1 })).then
      .to_return(status: 429, body: Factory.rate_limit_error(data: { retryAfter: 1 })).then
      .to_return(status: 429, body: Factory.rate_limit_error(data: { retryAfter: 1 })).then
      .to_return(status: 200, body: Factory.valid_address_res_json)
    start = Time.now
    client.validate_address(Factory.valid_address_params)
    diff = Time.now - start
    assert(diff > 3 && diff < 4, "should take between 3 and 4 seconds")
    assert_requested(stub, times: retries + 1)
  end

  tag :slow, :simengine
  # DX-1499 - Retry after should never exceed the timeout config value
  it "Functional test: Retry after should never exceed the timeout config value" do
    emitter = ShipEngine::Emitter::EventEmitter.new
    on_request_sent = Spy.on(emitter, :on_request_sent)
    on_response_received = Spy.on(emitter, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", emitter: emitter, timeout: 1000)

    assert_raises_shipengine_timeout({ message: "The request took longer than the 1000 milliseconds allowed" }) do
      client.validate_address(Factory.rate_limit_address_params)
    end

    assert_called(1, on_request_sent)
    assert_called(1, on_response_received)

    request_sent_event, _ = get_dispatched_events(on_request_sent)
    assert_request_sent_event({ retry_attempt: 0, timeout: 1000 }, request_sent_event)
  end
end
