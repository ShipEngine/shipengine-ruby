# frozen_string_literal: true

require 'test_helper'
require 'shipengine/exceptions'
require 'json'

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
    describe 'common functionality' do
      it 'the global config should not be mutated if overridden at method call time' do
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

    describe 'timeout' do
      it 'Should throw an error if timeout is invalid at instantiation or at method call' do
        def assert_timeout_validation_err(err)
          assert_error(err, message: 'Timeout must be greater than zero.', code: :invalid_field_value)
          assert_nil(err.request_id)
        end

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          ShipEngine::Client.new(api_key: 'abc1234', timeout: 0)
        end
        assert_timeout_validation_err(err)

        # config during instantiation and method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.timeout = -1
          client.validate_address(valid_address_params)
        end
        assert_timeout_validation_err(err)

        # config during method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.validate_address(valid_address_params, { timeout: -1 })
        end
        assert_timeout_validation_err(err)

        assert_not_requested(stub)
        ShipEngine::Client.new(api_key: 'abc1234', timeout: 5) # valid timeout
      end
    end

    describe 'retries' do
      it 'Should throw an error if retries is invalid at instantiation or at method call' do
        def assert_retries_validation_err(err)
          assert_error(err, message: 'Retries must be zero or greater.', code: :invalid_field_value)
          assert_nil(err.request_id)
        end

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          ShipEngine::Client.new(api_key: 'abc1234', retries: -1)
        end
        assert_retries_validation_err(err)

        # config during instantiation and method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.retries = -1
          client.validate_address(valid_address_params)
        end
        assert_retries_validation_err(err)

        # config during method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.validate_address(valid_address_params, { retries: -1 })
        end
        assert_retries_validation_err(err)

        assert_not_requested(stub)

        ShipEngine::Client.new(api_key: 'abc1234', retries: 5) # valid
        ShipEngine::Client.new(api_key: 'abc1234', retries: 0) # valid
      end

      it 'Should not throw an error if retries is valid' do
        stub_request(:post, base_url)
          .with(body: /.*/)
          .to_return(status: 200, body: valid_address_res)

        client = ShipEngine::Client.new(api_key: 'abc1234')
        client.configuration.retries = 2
        client.validate_address(valid_address_params)
        client.configuration.retries = 0
        client.validate_address(valid_address_params)
      end
    end

    describe 'api_key' do
      it 'should have header: API-Key if api-key passed during initialization' do
        stub = stub_request(:post, base_url)
               .with(body: /.*/, headers: { 'API-Key' => 'foo' }).to_return(status: 200, body: valid_address_res)

        client = ::ShipEngine::Client.new(api_key: 'foo')
        client.validate_address(valid_address_params)
        assert_requested(stub)
      end

      it 'should throw an error if api_key is invalid at instantiation or at method call' do
        def assert_api_key_error(err)
          assert_error(err,
                       source: 'shipengine',
                       type: 'validation',
                       code: :field_value_required,
                       message: 'A ShipEngine API key must be specified.')
        end

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          ShipEngine::Client.new(api_key: nil)
        end
        assert_api_key_error(err)

        # config during instantiation and method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.api_key = nil
          client.validate_address(valid_address_params)
        end
        assert_api_key_error(err)

        # config during method call
        err = assert_raises ShipEngine::Exceptions::ValidationError do
          client = ShipEngine::Client.new(api_key: 'foo')
          client.validate_address(valid_address_params, { api_key: nil })
        end
        assert_api_key_error(err)

        assert_not_requested(stub)

        ShipEngine::Client.new(api_key: 'abc1234') # valid
        ShipEngine::Client.new(api_key: 'abc1234') # valid
      end
    end
  end
end
