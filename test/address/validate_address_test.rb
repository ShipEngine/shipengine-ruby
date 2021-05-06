# frozen_string_literal: true

require 'test_helper'

describe 'Validate Address' do
  def assert_api_key_error(err)
    assert_equal err.source, 'shipengine'
    assert_equal err.type, 'validation'
    assert_equal err.code, 'field_value_required'
    assert_equal err.message, 'A ShipEngine API key must be specified.'
  end
  it 'Should throw a validation error if api_key is nil during instantiation' do
    ShipEngine::Client.new(api_key: nil)
    raise 'force fail 1'
    rescue ShipEngine::Exceptions::FieldValueRequired => e
      assert_api_key_error(e)
    else
      raise 'force fail 2'
    end
  it 'I should be able to override an API Key (or any method) after instantiation' do
    client = ShipEngine::Client.new(api_key: 'myapikey123')

    client.configuration.api_key= nil

    client.validate_address(street: ["city"], country_code: "US", postal_code: "02215")
    raise "force fail 1"
    rescue ::ShipEngine::Exceptions::FieldValueRequired => err
      # should throw an error since api key is nil
      assert_api_key_error(err)
    else
      raise "force fail 2"
  end
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
    client = ::ShipEngine::Client.new(api_key: 'abc123')
    client.validate_address(
      street: nil,
      city_locality: 'Houston',
      postal_code: '77002',
      state_province: 'TX',
      country_code: nil
    )
  rescue ShipEngine::Exceptions::ShipEngineError => e
    assert e.source.is_a?(String)
    assert e.type.is_a?(String)
    assert e.code.is_a?(String)
    assert e.message.is_a?(String)
  else
    raise 'force fail'
  end
end
