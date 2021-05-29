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
    subscriber = ShipEngine::Subscriber::EventEmitter.new
    on_request_sent = Spy.on(subscriber, :on_request_sent)

    client = ShipEngine::Client.new(api_key: "abc123", retries: 2, subscriber: subscriber) # emitter = MyEventEmitter.double(MyEventEmitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)
    assert_raises_rate_limit_error(retries: 2) { client.validate_address(Factory.valid_address_params) }

    assert_equal(3, on_request_sent.calls.count, "should be called three times")

    arg_call_1 = on_request_sent.calls[0].args[0]
    assert_kind_of(::ShipEngine::Subscriber::RequestSentEvent, arg_call_1, "on_request_sent should be called with a RequestSentEvent")
    assert_equal(Factory.valid_address_params[:street], arg_call_1.body.dig("params", "address", "street"),
      "on_request_sent should be passed the body (as a hash)")
    assert_equal(0, arg_call_1.retries, "should say the number of retries")
    assert_equal("Calling the ShipEngine address.validate.v1 API at https://simengine.herokuapp.com/jsonrpc", arg_call_1.message,
      "should have a message")
    assert_equal(::ShipEngine::Subscriber::EventType::REQUEST_SENT, arg_call_1.type, "should have a type")

    arg_call_2 = on_request_sent.calls[1].args[0]
    assert_equal(1, arg_call_2.retries)

    arg_call_3 = on_request_sent.calls[2].args[0]
    assert_equal(2, arg_call_3.retries)
  end

  it "should dispatch an on_response_received three times (once to start and twice more for every retry)" do
    class MyEventEmitter < ShipEngine::Subscriber::EventEmitter
      def on_response_received(event); end
    end

    subscriber = MyEventEmitter.new
    on_response_received = Spy.on(subscriber, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", retries: 2, subscriber: subscriber) # emitter = MyEventEmitter.double(MyEventEmitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)

    assert_raises_rate_limit_error(retries: 2) { client.validate_address(Factory.valid_address_params) }

    assert_equal(3, on_response_received.calls.count, "should be called three times")

    arg_call_1 = on_response_received.calls[0].args[0]
    assert_kind_of(
      ::ShipEngine::Subscriber::ResponseReceivedEvent,
      arg_call_1,
      "on_request_sent should be called with a ResponseReceivedEvent"
    )
    assert_equal(0, arg_call_1.retries)

    assert_kind_of(Hash, arg_call_1.body)
    assert_equal(
      "You have exceeded the rate limit.",
      arg_call_1.body["error"]["message"],
      "on_response_received hould be passed the response body (as a hash)"
    )

    timestamp_diff = Time.now - arg_call_1.datetime
    assert_equal(true, timestamp_diff > 0 && timestamp_diff < 1, "timestamp_d should be less than a second from now")

    assert_equal("Received an HTTP 429 response from the ShipEngine address.validate.v1 API", arg_call_1.message, "should have a message")
    assert_equal(::ShipEngine::Subscriber::EventType::RESPONSE_RECEIVED, arg_call_1.type, "should have a type")

    arg_call_2 = on_response_received.calls[1].args[0]
    assert_equal(1, arg_call_2.retries)

    arg_call_3 = on_response_received.calls[2].args[0]
    assert_equal(2, arg_call_3.retries)
  end

  it "should dispatch an on_request_sent once" do
    subscriber = ShipEngine::Subscriber::EventEmitter.new
    on_request_sent = Spy.on(subscriber, :on_request_sent)

    client = ShipEngine::Client.new(api_key: "abc123", subscriber: subscriber) # emitter = MyEventEmitter.double(MyEventEmitter)

    stub_request(:post, SIMENGINE_URL)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    response = client.validate_address(Factory.valid_address_params)
    assert response
    assert_equal(1, on_request_sent.calls.count, "should be called once")

    arg_call_1 = on_request_sent.calls[0].args[0]
    assert_kind_of(::ShipEngine::Subscriber::RequestSentEvent, arg_call_1, "on_request_sent should be called with a RequestSentEvent")
    assert_equal(::ShipEngine::Subscriber::EventType::REQUEST_SENT, arg_call_1.type, "should have a type")
    assert_equal(0, arg_call_1.retries, "should say the number of retries")

    assert_kind_of(Time, arg_call_1.datetime)
    assert_kind_of(Hash, arg_call_1.body)
    assert_kind_of(Hash, arg_call_1.body.dig("params", "address"), "on_request_sent should be passed the body (as a hash)")

    assert_equal(
      "Calling the ShipEngine address.validate.v1 API at https://simengine.herokuapp.com/jsonrpc",
      arg_call_1.message,
      "should have a message"
    )
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
    subscriber = ShipEngine::Subscriber::EventEmitter.new
    on_request_sent = Spy.on(subscriber, :on_request_sent)
    on_response_received = Spy.on(subscriber, :on_response_received)
    client = ShipEngine::Client.new(api_key: "abc123", retries: 0, subscriber: subscriber)
    client.validate_address(Factory.valid_address_params)

    assert_equal(1, on_request_sent.calls.count, "one http request event should have occurred")
    assert_equal(1, on_response_received.calls.count, "one http response events should have occurred")
    request_sent_event = on_request_sent.calls[0].args[0]
    response_received_event = on_response_received.calls[0].args[0]
    assert_raises_rate_limit_error(retries: 0) do
      client.validate_address(Factory.rate_limit_address_params)
    end
    assert_equal(0, request_sent_event.retries, "request sent retries should be 0")
    assert_equal(0, response_received_event.retries, "response received retries should be 0")
  end

  # DX-1500
  it "Functional test: Should retry 1 time after waiting 3 seconds" do
    class MyEventEmitter < ShipEngine::Subscriber::EventEmitter
      def on_request_sent(event); end

      def on_response_received(event); end
    end

    subscriber = MyEventEmitter.new
    on_request_sent = Spy.on(subscriber, :on_request_sent)
    on_response_received = Spy.on(subscriber, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", subscriber: subscriber)

    start = Time.now
    assert_raises_rate_limit_error { client.validate_address({ street: ["429 Rate Limit Error"], postal_code: "78751", country: "US" }) }
    diff = Time.now - start
    assert(diff > 3 && diff < 4, "should take between 3 and 4 seconds. Took #{diff} seconds.")
    assert_equal(2, on_request_sent.calls.count, "two http request events occurred")
    assert_equal(2, on_response_received.calls.count, "two http response events occurred")

    event_1_time = on_request_sent.calls[0].args[0].datetime
    event_2_time = on_request_sent.calls[1].args[0].datetime
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
    subscriber = ShipEngine::Subscriber::EventEmitter.new
    on_request_sent = Spy.on(subscriber, :on_request_sent)
    on_response_received = Spy.on(subscriber, :on_response_received)

    client = ShipEngine::Client.new(api_key: "abc123", subscriber: subscriber, timeout: 1000)

    assert_raises_shipengine_timeout({ message: "The request took longer than the 1000 milliseconds allowed" }) do
      client.validate_address(Factory.rate_limit_address_params)
    end

    assert_equal(1, on_request_sent.calls.count, "one http request event should have occurred")
    assert_equal(1, on_response_received.calls.count, "one http response events should have occurred")
    request_sent_event = on_request_sent.calls[0].args[0]

    assert_equal(0, request_sent_event.retries, "retries should be 0")
    assert_equal(1000, request_sent_event.timeout, "timeout should be 1000 ms")
  end
end
