# frozen_string_literal: true

require "test_helper"

describe "Configuration" do
  describe "common functionality" do
    it "should accept an api_key only constructor" do
      client = ::ShipEngine::Client.new("foo")

      # the global configuration should not be mutated
      assert_equal "foo", client.configuration.api_key
    end
    it "default values should be passed" do
      client = ::ShipEngine::Client.new("foo")

      # the global configuration should not be mutated
      assert_equal 30_000, client.configuration.timeout
      assert_equal 50, client.configuration.page_size
    end
    it "the global config should not be mutated if overridden at method call time" do
      stub = stub_request(:post, SIMENGINE_URL)
        .with(body: /.*/, headers: { "API-Key" => "baz" })
        .to_return(status: 200, body: Factory.valid_address_res_json)

      client = ::ShipEngine::Client.new("foo", timeout: 111_000)
      assert_equal "foo", client.configuration.api_key
      assert_equal 111_000, client.configuration.timeout

      # override
      client.configuration.api_key = "bar"
      client.configuration.timeout = 222_000
      client.validate_address(Factory.valid_address_params, { api_key: "baz", timeout: 222_000 })
      assert_requested(stub)

      # the global configuration should not be mutated
      assert_equal "bar", client.configuration.api_key
      assert_equal 222_000, client.configuration.timeout

      # any default arguments should continue to be passed down.
      assert_equal 50, client.configuration.page_size
    end
  end

  describe "page_size" do
    it "Should throw an error if page size is invalid at instantiation or at method call" do
      page_size_err = { message: "Page size must be greater than zero.", code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

      stub = stub_request(:post, SIMENGINE_URL)
        .with(body: /.*/)
        .to_return(status: 200, body: Factory.valid_address_res_json)

      # configuration during insantiation
      assert_raises_shipengine_validation(page_size_err) do
        ::ShipEngine::Client.new("abc1234", page_size: 0)
      end

      # config during instantiation and method call
      assert_raises_shipengine_validation(page_size_err) do
        client = ::ShipEngine::Client.new("abc1234")
        client.configuration.page_size = 0
        client.validate_address(Factory.valid_address_params)
      end

      # config during method call
      assert_raises_shipengine_validation(page_size_err) do
        client = ShipEngine::Client.new("abc1234")
        client.validate_address(Factory.valid_address_params, { page_size: 0 })
      end

      assert_not_requested(stub)
      ShipEngine::Client.new("abc1234", page_size: 5)
    end
  end

  describe "User Agent header" do
    # DX-1487 - User agent includes correct SDK version
    it "should pass a user agent header with a version (this tests indirectly per the emitter)" do
      emitter = ::ShipEngine::Emitter::EventEmitter.new
      on_request_sent = Spy.on(emitter, :on_request_sent)
      client = ::ShipEngine::Client.new("abc123", emitter: emitter)
      client.validate_address(Factory.valid_address_params)
      request_sent_event, _ = get_dispatched_events(on_request_sent)
      user_agent = request_sent_event.headers["User-Agent"]
      refute(user_agent.match(/nil/i))
      assert_equal(user_agent, "shipengine-ruby/#{::ShipEngine::VERSION} (#{RUBY_PLATFORM})")
    end
  end

  describe "api_key" do
    it "should have header: API-Key if api-key passed during initialization" do
      stub = stub_request(:post, SIMENGINE_URL)
        .with(body: /.*/, headers: { "API-Key" => "foo" }).to_return(status: 200, body: Factory.valid_address_res_json)

      client = ::ShipEngine::Client.new("foo")
      client.validate_address(Factory.valid_address_params)
      assert_requested(stub)
    end

    it "should throw an error if api_key is invalid at instantiation or at method call" do
      api_key_err = {
        source: "shipengine",
        type: "validation",
        code: ::ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED),
        message: "A ShipEngine API key must be specified.",
      }

      stub = stub_request(:post, SIMENGINE_URL)
        .with(body: /.*/)
        .to_return(status: 200, body: Factory.valid_address_res_json)

      # configuration during insantiation
      assert_raises_shipengine_validation(api_key_err) do
        ShipEngine::Client.new(nil)
      end

      # config during instantiation and method call
      assert_raises_shipengine_validation(api_key_err) do
        client = ShipEngine::Client.new("abc1234")
        client.configuration.api_key = nil
        client.validate_address(Factory.valid_address_params)
      end

      # config during method call
      assert_raises_shipengine_validation(api_key_err) do
        client = ShipEngine::Client.new("foo")
        client.validate_address(Factory.valid_address_params, { api_key: nil })
      end

      assert_not_requested(stub)

      ShipEngine::Client.new("abc1234") # valid
      ShipEngine::Client.new("abc1234") # valid
    end
  end
end
