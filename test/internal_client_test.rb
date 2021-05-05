# frozen_string_literal: true

require 'test_helper'

base_url = 'https://simengine.herokuapp.com/jsonrpc'
describe 'Internal client test' do
  it 'Should make a request' do
    client = ShipEngine::InternalClient.new(api_key: 'abc123', base_url: base_url)
    params = { address: {
      street: ['501 Crawford St'],
      cityLocality: 'Houston',
      postalCode: '77002',
      stateProvince: 'TX',
      countryCode: 'US'
    } }
    success_request = client.make_request('address.validate.v1', params)
    assert success_request
  end

  describe 'Errors' do
    def assert_api_key_error(err)
      assert err.source == 'shipengine'
      assert err.type == 'validation'
      assert err.code == 'field_value_required'
      assert err.message == 'A ShipEngine API key must be specified.'
    end

    it 'Should throw a validation error if api_key is nil during instantiation' do
      _ = ShipEngine::InternalClient.new(api_key: nil, base_url: base_url)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert_api_key_error(e)
    else
      raise 'force fail'
    end
    it 'Should throw a validation error if api_key is empty string during instantiation' do
      _ = ShipEngine::InternalClient.new(api_key: '', base_url: base_url)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert_api_key_error(e)
    else
      raise 'force fail'
    end
  end
end
