# frozen_string_literal: true

require 'test_helper'

describe 'Internal client test' do
  it 'Should make a request' do
    client = ShipEngine::InternalClient.new(api_key: 'abc123')
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
    def assert_api_key_error(err)
      assert err.source == 'shipengine'
      assert err.type == 'validation'
      assert err.code == 'field_value_required'
      assert err.message == 'A ShipEngine API key must be specified.'
    end

    it 'Should throw a validation error if no api_key passed during instantiation' do
      _ = ShipEngine::InternalClient.new(api_key: nil)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert_api_key_error(e)
    else
      raise 'force fail'
    end
    it 'Should throw a validation error if api_key is empty string during instantiation' do
      _ = ShipEngine::InternalClient.new(api_key: nil)
      raise 'force fail'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert_api_key_error(e)
    else
      raise 'force fail'
    end
  end
end
