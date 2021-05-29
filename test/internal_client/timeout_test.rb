# frozen_string_literal: true
require "test_helper"

describe "timeout" do
  it "Should throw an error if timeout is invalid at instantiation or at method call" do
    timeout_err = { message: "Timeout must be greater than zero.", code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

    stub = stub_request(:post, SIMENGINE_URL)
      .with(body: /.*/)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    # configuration during insantiation
    assert_raises_shipengine_validation(timeout_err) do
      ::ShipEngine::Client.new(api_key: "abc1234", timeout: 0)
    end

    # config during instantiation and method call
    assert_raises_shipengine_validation(timeout_err) do
      client = ::ShipEngine::Client.new(api_key: "abc1234")
      client.configuration.timeout = -1
      client.validate_address(Factory.valid_address_params)
    end

    # config during method call
    assert_raises_shipengine_validation(timeout_err) do
      client = ShipEngine::Client.new(api_key: "abc1234")
      client.validate_address(Factory.valid_address_params, { timeout: -1 })
    end

    assert_not_requested(stub)
    ShipEngine::Client.new(api_key: "abc1234", timeout: 5000) # valid timeout
  end
end
