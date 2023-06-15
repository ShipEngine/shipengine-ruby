# frozen_string_literal: true

require 'test_helper'
require 'pry'

describe 'retries' do
  after do
    WebMock.reset!
  end
  it 'Should throw an error if retries is invalid at instantiation or at method call' do
    retries_err = { message: 'Retries must be zero or greater.', code: ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: /.*/)
           .to_return(status: 200, body: Factory.valid_address_res_json)

    # configuration during insantiation
    assert_raises_shipengine_validation(retries_err) do
      ShipEngine::Client.new('abc1234', retries: -1)
    end

    # config during instantiation and method call
    assert_raises_shipengine_validation(retries_err) do
      client = ShipEngine::Client.new('abc1234')
      client.configuration.retries = -1
      client.validate_addresses(Factory.valid_address_params)
    end

    # config during method call
    assert_raises_shipengine_validation(retries_err) do
      client = ShipEngine::Client.new('abc1234')
      client.validate_addresses(Factory.valid_address_params, { retries: -1 })
    end

    assert_not_requested(stub)

    ShipEngine::Client.new('abc1234', retries: 5) # valid
    ShipEngine::Client.new('abc1234', retries: 0) # valid
  end

  it 'Should not throw an error if retries is valid' do
    stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
      .with(body: /.*/)
      .to_return(status: 200, body: Factory.valid_address_res_json)

    client = ShipEngine::Client.new('abc1234')
    client.configuration.retries = 2
    client.validate_addresses(Factory.valid_address_params)
    client.configuration.retries = 0
    client.validate_addresses(Factory.valid_address_params)
  end

  it 'should have a default value of 1' do
    client = ShipEngine::Client.new('abc1234')
    assert_equal(1, client.configuration.retries)
  end

  it 'should retry once again on a 429 (default)' do
    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 200, body: Factory.valid_address_res_json)

    client = ShipEngine::Client.new('abc123', retries: 2)
    response = client.validate_addresses(Factory.valid_address_params)
    assert_equal(response[0].status, 'verified')
    assert_requested(stub, times: 3)
  end

  it 'should stop retrying if retries is exhausted (and return rate limit error)' do
    client = ShipEngine::Client.new('abc123', retries: 2)
    stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)

    assert_raises_rate_limit_error { client.validate_addresses(Factory.valid_address_params) }
  end

  it 'should throw an error with the number of tries' do
    client = ShipEngine::Client.new('abc123', retries: 2)
    stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)

    assert_raises_rate_limit_error(retries: 2) { client.validate_addresses(Factory.valid_address_params) }
  end

  it 'respects the Retry-After header, which can override error.retryAfter' do
    client = ShipEngine::Client.new('abc123', retries: 1)
    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .to_return(status: 429, body: Factory.rate_limit_error, headers: { 'Retry-After': 1 })
           .then.to_return(status: 200, body: Factory.valid_address_res_json)
    start = Time.now
    client.validate_addresses(Factory.valid_address_params)
    diff = Time.now - start

    assert_operator(diff, :>, 1, 'should take more than than 1 second')
    assert_requested(stub, times: 2)
  end

  it 'should not make any additional retries if retries is disabled (i.e. set to 0)' do
    client = ShipEngine::Client.new('abc123', retries: 0)
    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 200, body: Factory.valid_address_res_json)
    assert_raises_rate_limit_error { client.validate_addresses(Factory.valid_address_params) }
    assert_requested(stub, times: 1)
  end

  it 'should dispatch an on_request_sent three times (once to start and twice more for every retry)' do
    client = ShipEngine::Client.new('abc123', retries: 2)

    stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error).then
      .to_return(status: 429, body: Factory.rate_limit_error)
    assert_raises_rate_limit_error(retries: 2) { client.validate_addresses(Factory.valid_address_params) }
  end

  it 'should make requests immediately if retryAfter is set to 0' do
    retries = 2
    client = ShipEngine::Client.new('abc123', retries:)
    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 429, body: Factory.rate_limit_error).then
           .to_return(status: 200, body: Factory.valid_address_res_json)
    start = Time.now
    client.validate_addresses(Factory.valid_address_params)
    diff = Time.now - start
    assert_operator(diff, :<, 1, 'should take less than 1 second')
    assert_requested(stub, times: retries + 1)
  end
end
