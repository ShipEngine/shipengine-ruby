require 'test_helper'

describe 'Client test' do
  it 'Should make a request' do
    client = ::ShipEngine::PlatformClient.new(api_key: 'abc123')
    params = { address: {
      street: ['501 Crawford St'],
      city_locality: 'Houston',
      postal_code: '77002',
      state_province: 'TX',
      country_code: 'US'
    } }
    success_request = client.make_request('address/validate', params)
    assert success_request
  end
end
