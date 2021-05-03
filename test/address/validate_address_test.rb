require 'test_helper'

describe 'Validate Address' do
  it 'Should successfully validate an address' do
    client = ::ShipEngine::Client.new(api_key: 'abc123')
    valid_address = {
      street: ['501 Crawford St'],
      city_locality: 'Houston',
      postal_code: '77002',
      state_province: 'TX',
      country_code: 'US'
    }
    success_request = client.validate_address(valid_address)
    assert success_request
  end
end
