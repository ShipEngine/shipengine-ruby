# frozen_string_literal: true

require 'test_helper'
require 'shipengine'

def assert_api_key_error(err)
  assert_equal 'shipengine', err.source
  assert_equal 'validation', err.type
  assert_equal :field_value_required, err.code
  assert_equal 'A ShipEngine API key must be specified.', err.message
end

exceptions = ::ShipEngine::Exceptions

def assert_error_message(error_class, expected_message = nil, &block)
  err = assert_raises error_class, &block
  assert_match(/#{expected_message}/, err.message) unless expected_message.nil?
  err
end

describe 'Validate Address' do
  describe 'Configuration' do
    it 'Should throw a validation error if api_key is nil during instantiation' do
      err = assert_error_message(exceptions::FieldValueRequired) do
        ::ShipEngine::Client.new(api_key: nil)
      end
      assert_api_key_error(err)
    end

    it 'I should be able to override an API Key (or any method) after instantiation' do
      err = assert_error_message(exceptions::FieldValueRequired) do
        client = ShipEngine::Client.new(api_key: 'myapikey123')
        client.configuration.api_key = nil
        client.validate_address({ street: ['city'], country_code: 'US', postal_code: '02215' })
      end
      assert_api_key_error(err)
    end

    it 'I should be able to override an API Key as an options argument' do
      client = ShipEngine::Client.new(api_key: 'my_api_key_1')
      client.configuration.api_key = 'my_api_key_2'
      client.validate_address(
        { street: ['city'], country_code: 'US', postal_code: '02215' },
        { api_key: 'my_final_api_key' }
      )
    end
  end

  it 'Should successfully validate an address' do
    client = ::ShipEngine::Client.new(api_key: 'abc123')
    success_request = client.validate_address({
                                                street: ['501 Crawford St'],
                                                city_locality: 'Houston',
                                                postal_code: '77002',
                                                state_province: 'TX',
                                                country_code: 'US'
                                              })
    assert success_request
  end

  it 'should propgate server errors if server response has error' do
    err = assert_error_message(exceptions::ShipEngineError) do
      client = ::ShipEngine::Client.new(api_key: 'abc123')
      client.validate_address(
        street: nil,
        city_locality: 'Houston',
        postal_code: '77002',
        state_province: 'TX',
        country_code: nil
      )
    end
    assert_equal exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), err.code
    assert_equal 'shipengine', err.source
    assert_equal 'validation', err.type
    assert err.message.is_a?(String)
  end
end
