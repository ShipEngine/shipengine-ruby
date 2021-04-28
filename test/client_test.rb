require 'test_helper'
require 'pry'
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

  it 'Should throw Errors' do
    client = ::ShipEngine::PlatformClient.new(api_key: 'abc123')
    client.make_request('address/validate', { foo: 'invalid request' })
    raise 'should not happen'
  rescue ShipEngine::Exceptions::ShipEngineError => e
    assert e.message.is_a?(String)
  else
    raise 'should not happen'
  end
end
