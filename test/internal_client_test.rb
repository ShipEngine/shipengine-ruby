require 'test_helper'

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

  describe 'Errors' do

    it 'Should throw a validation error if no api_key passed during instantiation' do
      _ = ::ShipEngine::InternalClient.new(api_key: nil)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert e.source == 'shipengine'
      assert e.type == 'validation'
      assert e.code == ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED)
      assert e.message == 'A ShipEngine API key must specified.'
    else
      raise 'force fail'
    end
    it 'Should throw a validation error if api_key is empty string during instantiation' do
      _ = ::ShipEngine::InternalClient.new(api_key: nil)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert e.message.is_a?(String)
    else
      raise 'force fail'
    end
  end
end
