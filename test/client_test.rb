require 'test_helper'

describe 'Client test' do
  it 'Should make a request' do
    client = ::ShipEngine::PlatformClient.new(api_key: 'abc123')
    b = client.make_request(method: 'post', route: 'v1/address/validate', body: {
                              'street' => ['501 Crawford St'],
                              'city_locality' => 'Houston',
                              'postal_code' => '77002',
                              'state_province' => 'TX',
                              'country_code' => 'US'
                            })
    puts b.inspect
    assert b.inspect
  end
end
