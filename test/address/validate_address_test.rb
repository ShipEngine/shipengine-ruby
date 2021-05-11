# frozen_string_literal: true

require 'test_helper'
require 'shipengine'

exceptions = ::ShipEngine::Exceptions

describe 'Validate Address' do
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
    client = ::ShipEngine::Client.new(api_key: 'abc123')
    err = assert_raises exceptions::ValidationError do
      client.validate_address({
                                street: nil,
                                city_locality: 'Houston',
                                postal_code: '77002',
                                state_province: 'TX',
                                country_code: nil
                              })
    end
    assert_equal exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), err.code
    assert_equal 'shipengine', err.source
    assert_equal 'validation', err.type
    assert err.message.is_a?(String)
  end
end
