# frozen_string_literal: true

require 'test_helper'
require 'shipengine/exceptions'
require 'json'
def assert_api_key_error(err)
  assert_error(err,
               source: 'shipengine',
               type: 'validation',
               code: :field_value_required,
               message: 'A ShipEngine API key must be specified.')
end

def assert_error(err, message: nil, source: 'shipengine', type: nil, code: nil)
  assert_equal source, err.source if source
  assert_equal type, err.type if type
  assert_equal code, err.code if code
  assert_equal message, err.message if message
end

valid_address_params = {
  street: ['104 Foo Street'], postal_code: '78751', country: 'US'
}

valid_address_res = JSON.generate({
                                    jsonrpc: '2.0',
                                    id: 'req_123456',
                                    result: {
                                      isValid: true,
                                      normalizedAddress: {
                                        name: '',
                                        company: '',
                                        phone: '',
                                        street: [
                                          '104 NELRAY'
                                        ],
                                        cityLocality: 'METROPOLIS',
                                        stateProvince: 'ME',
                                        postalCode: '02215',
                                        countryCode: 'US',
                                        isResidential: nil
                                      },
                                      messages: []
                                    }
                                  })

describe 'Internal Client Tests' do
  after do
    WebMock.reset!
  end

  base_url = 'https://simengine.herokuapp.com/jsonrpc'
  describe 'Configuration' do
    it 'Should throw a validation error if api_key is nil during instantiation' do
      err = assert_raises ShipEngine::Exceptions::ValidationError do
        ShipEngine::Client.new(api_key: nil)
      end
      assert_api_key_error(err)
    end

    it 'Should throw an error if timeout is invalid' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/)

      client = ShipEngine::Client.new(api_key: 'abc1234')
      client.configuration.timeout = 0

      # the fact that this an InvalidFieldValue error means I don't need to test the constants on that class.
      err = assert_raises ShipEngine::Exceptions::ValidationError do
        client.validate_address(valid_address_params)
      end
      assert_nil(err.request_id)
      assert_error(err, message: 'Timeout must be greater than zero.', code: :invalid_field_value)
      assert_not_requested(stub)
    end

    it 'Should throw an error if retries is set to a negative integer' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/)
             .to_return(status: 200, body: valid_address_res)

      client = ShipEngine::Client.new(api_key: 'abc1234')
      client.configuration.retries = -1
      err = assert_raises ShipEngine::Exceptions::ShipEngineError do
        client.validate_address(valid_address_params)
      end
      assert_nil(err.request_id)
      assert_error(err, message: 'Retries must be zero or greater.', code: :invalid_field_value)
      assert_not_requested(stub)
    end

    it 'Should work if retries is valid' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/)
             .to_return(status: 200, body: valid_address_res)

      client = ShipEngine::Client.new(api_key: 'abc1234')
      client.configuration.retries = 2
      client.validate_address({ street: ['104 Foo Street'], postal_code: '78751', country: 'US' })

      assert_requested(stub)
      # this is an error, but it probably shouldn't be an INVALID FIELD VALUE ERROR
    end

    it 'Should throw an error if retries is set to a negative integer' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/)

      client = ShipEngine::Client.new(api_key: 'abc1234')
      client.configuration.retries = -1
      err = assert_raises ShipEngine::Exceptions::ValidationError do
        client.validate_address(valid_address_params)
      end
      assert_nil(err.request_id)
      assert_error(err, message: 'Retries must be zero or greater.')
      assert_not_requested(stub)
    end

    it 'should have header: API-Key if api-key passed during initialization' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'foo' }).to_return(status: 200, body: valid_address_res)

      client = ::ShipEngine::Client.new(api_key: 'foo')
      client.validate_address(valid_address_params)
      assert_requested(stub)
    end

    it 'should have header: API-Key and global configuration should be able to be changed on class' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'bar' })
             .to_return(status: 200, body: valid_address_res)

      client = ::ShipEngine::Client.new(api_key: 'foo')
      # override "foo"
      client.configuration.api_key = 'bar'

      client.validate_address(valid_address_params)
      assert_requested(stub)
    end

    it 'should have header: API-Key and configuration should be overriddeable on a per-call basis,
        but the global config should not change' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'baz' })
             .to_return(status: 200, body: valid_address_res)

      client = ::ShipEngine::Client.new(api_key: 'foo')
      # override "foo"
      client.configuration.api_key = 'bar'
      # override "bar"
      client.validate_address(valid_address_params, { api_key: 'baz' })
      assert_requested(stub)
      # the global configuration should not be mutated
      assert_equal client.configuration.api_key, 'bar'
    end
  end
end
