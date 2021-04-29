require 'test_helper'
require 'pry'
describe 'Internal client test' do
  it 'Should make a request' do
    client = ::ShipEngine::InternalClient.new(api_key: 'abc123')
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
    client = ::ShipEngine::InternalClient.new(api_key: 'abc123')
    client.make_request('address/validate', { foo: 'invalid request' })
    raise 'force fail'
  rescue ShipEngine::Exceptions::ShipEngineErrorDetailed => e
    assert e.source.is_a?(String)
    assert e.type.is_a?(String)
    assert e.code.is_a?(String)
    assert e.message.is_a?(String)
  else
    raise 'force fail'
  end
end
