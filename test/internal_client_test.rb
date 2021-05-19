# frozen_string_literal: true

require 'test_helper'
require 'shipengine/exceptions'
require 'shipengine'
require 'json'

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
      it 'default values should be passed' do
        client = ::ShipEngine::Client.new(api_key: 'foo')

        # the global configuration should not be mutated
        assert_equal 5, client.configuration.timeout
        assert_equal 50, client.configuration.page_size
      end
      it 'the global config should not be mutated if overridden at method call time' do
        stub = stub_request(:post, base_url)
               .with(body: /.*/, headers: { 'API-Key' => 'baz' })
               .to_return(status: 200, body: valid_address_res)

        client = ::ShipEngine::Client.new(api_key: 'foo', timeout: 111)
        assert_equal 'foo', client.configuration.api_key
        assert_equal 111, client.configuration.timeout

        # override
        client.configuration.api_key = 'bar'
        client.configuration.timeout = 222
        client.validate_address(valid_address_params, { api_key: 'baz', timeout: 222 })
        assert_requested(stub)

        # the global configuration should not be mutated
        assert_equal 'bar', client.configuration.api_key
        assert_equal 222, client.configuration.timeout

        # any default arguments should continue to be passed down.
        assert_equal 50, client.configuration.page_size
      end
    end

    describe 'page_size' do
      it 'Should throw an error if page size is invalid at instantiation or at method call' do
        page_size_err = { message: 'Page size must be greater than zero.', code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        assert_raises_shipengine_validation(page_size_err) do
          ::ShipEngine::Client.new(api_key: 'abc1234', page_size: 0)
        end

        # config during instantiation and method call
        assert_raises_shipengine_validation(page_size_err) do
          client = ::ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.page_size = 0
          client.validate_address(valid_address_params)
        end

        # config during method call
        assert_raises_shipengine_validation(page_size_err) do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.validate_address(valid_address_params, { page_size: 0 })
        end

        assert_not_requested(stub)
        ShipEngine::Client.new(api_key: 'abc1234', page_size: 5)
      end
    end

    describe 'timeout' do
      it 'Should throw an error if timeout is invalid at instantiation or at method call' do
        timeout_err = { message: 'Timeout must be greater than zero.', code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        assert_raises_shipengine_validation(timeout_err) do
          ::ShipEngine::Client.new(api_key: 'abc1234', timeout: 0)
        end

        # config during instantiation and method call
        assert_raises_shipengine_validation(timeout_err) do
          client = ::ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.timeout = -1
          client.validate_address(valid_address_params)
        end

        # config during method call
        assert_raises_shipengine_validation(timeout_err) do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.validate_address(valid_address_params, { timeout: -1 })
        end

        assert_not_requested(stub)
        ShipEngine::Client.new(api_key: 'abc1234', timeout: 5) # valid timeout
      end
    end

    describe 'retries' do
      it 'Should throw an error if retries is invalid at instantiation or at method call' do
        retries_err = { message: 'Retries must be zero or greater.', code: ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE) }

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        assert_raises_shipengine_validation(retries_err) do
          ShipEngine::Client.new(api_key: 'abc1234', retries: -1)
        end

        # config during instantiation and method call
        assert_raises_shipengine_validation(retries_err) do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.retries = -1
          client.validate_address(valid_address_params)
        end

        # config during method call
        assert_raises_shipengine_validation(retries_err) do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.validate_address(valid_address_params, { retries: -1 })
        end

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
        api_key_err = {
          source: 'shipengine',
          type: 'validation',
          code: ::ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED),
          message: 'A ShipEngine API key must be specified.'
        }

        stub = stub_request(:post, base_url)
               .with(body: /.*/)
               .to_return(status: 200, body: valid_address_res)

        # configuration during insantiation
        assert_raises_shipengine_validation(api_key_err) do
          ShipEngine::Client.new(api_key: nil)
        end

        # config during instantiation and method call
        assert_raises_shipengine_validation(api_key_err) do
          client = ShipEngine::Client.new(api_key: 'abc1234')
          client.configuration.api_key = nil
          client.validate_address(valid_address_params)
        end

        # config during method call
        assert_raises_shipengine_validation(api_key_err) do
          client = ShipEngine::Client.new(api_key: 'foo')
          client.validate_address(valid_address_params, { api_key: nil })
        end

        assert_not_requested(stub)

        ShipEngine::Client.new(api_key: 'abc1234') # valid
        ShipEngine::Client.new(api_key: 'abc1234') # valid
      end
    end
  end
end
