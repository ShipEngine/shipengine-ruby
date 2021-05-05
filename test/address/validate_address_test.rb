# frozen_string_literal: true

require 'test_helper'

describe 'Validate Address' do
  it 'Should successfully validate an address' do
    client = ::ShipEngine::Client.new(api_key: 'abc123')
    success_request = client.validate_address(
      street: ['501 Crawford St'],
      city_locality: 'Houston',
      postal_code: '77002',
      state_province: 'TX',
      country_code: 'US'
    )
    assert success_request
  end
  it 'should propgate server errors if params are invalid' do
    client = ::ShipEngine::InternalClient.new(api_key: 'abc123')
    client.validate_address(
      street: ['Invalid request'],
      city_locality: 'Houston',
      postal_code: '77002',
      state_province: 'TX',
      country_code: 'US'
    )
  rescue ShipEngine::Exceptions::ShipEngineErrorDetailed => e
    assert e.source.is_a?(String)
    assert e.type.is_a?(String)
    assert e.code.is_a?(String)
    assert e.message.is_a?(String)
  else
    raise 'force fail'
  end
end
