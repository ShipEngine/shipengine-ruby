# frozen_string_literal: true

require 'test_helper'
require 'json'

def get_address(overrides = {})
  {
    name: 'John Smith',
    company: 'ShipMate',
    city_locality: 'Toronto',
    state_province: 'On',
    postal_code: 'M6K 3C3',
    country: 'CA',
    street: ['123 Foo', 'Some Other Line']
  }.merge(overrides)
end

describe 'Validate Address: Functional' do
  after do
    WebMock.reset!
  end
  client = ShipEngine::Client.new('TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s')

  it 'handles unauthorized errors' do
    params = [{
      address_line1: '500 Server Error',
      city_locality: 'Boston',
      state_province: 'MA',
      postal_code: '01152',
      country: 'US'
    }]

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: params.to_json)
           .to_return(status: 401, body: {
             'request_id' => 'cdc19c7b-eec7-4730-8814-462623a62ddb',
             'errors' => [{
               'error_source' => 'shipengine',
               'error_type' => 'security',
               'error_code' => 'unauthorized',
               'message' => 'The API key is invalid. Please see https://www.shipengine.com/docs/auth'
             }]
           }.to_json)

    expected_err = {
      source: 'shipengine',
      type: 'security',
      code: 'unauthorized',
      message: 'The API key is invalid. Please see https://www.shipengine.com/docs/auth'
    }

    assert_raises_shipengine(ShipEngine::Exceptions::ShipEngineError, expected_err) do
      client.validate_addresses(params)
      assert_requested(stub, times: 1)
    end
  end

  it 'Throws an error from shipengine' do
    params = [{
      name: 'John Smith',
      company_name: 'ShipStation',
      address_line1: '3800 N Lamar Blvd',
      address_line2: '#220',
      country_code: 'US',
      address_residential_indicator: false
    }]

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: params.to_json)
           .to_return(status: 400, body: {
             request_id: '27b5f201-5af2-4e93-a13b-833299a8a365',
             errors: [
               {
                 error_source: 'shipengine',
                 error_type: 'system',
                 error_code: 'unspecified',
                 message: 'addresses: Cannot deserialize the current JSON object (e.g. {"name":"value"})'
               }
             ]
           }.to_json)

    expected_err = {
      source: 'shipengine',
      type: 'system',
      code: 'unspecified',
      message: 'addresses: Cannot deserialize the current JSON object (e.g. {"name":"value"})'
    }

    assert_raises_shipengine(ShipEngine::Exceptions::ShipEngineError, expected_err) do
      client.validate_addresses(params)
      assert_requested(stub, times: 1)
    end
  end

  it 'should work with multi-line street addresses' do
    params = [{
      country_code: 'US',
      address_line1: '4 Jersey St.',
      address_line2: 'Suite 200',
      address_line3: '2nd Floor',
      city_locality: 'Boston',
      state_province: 'MA',
      postal_code: '02215'
    }]

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: params.to_json)
           .to_return(status: 200, body: [{
             status: 'verified',
             original_address: {
               name: nil,
               company_name: nil,
               address_line1: '4 Jersey St.',
               address_line2: 'Suite 200',
               address_line3: '2nd Floor',
               phone: nil,
               city_locality: 'Boston',
               state_province: 'MA',
               postal_code: '02215',
               country_code: 'US',
               address_residential_indicator: 'unknown'
             },
             matched_address: {
               name: nil,
               company_name: nil,
               address_line1: '4 JERSEY ST STE 200',
               address_line2: '',
               address_line3: '2ND FLOOR',
               phone: nil,
               city_locality: 'BOSTON',
               state_province: 'MA',
               postal_code: '02215-4148',
               country_code: 'US',
               address_residential_indicator: 'no'
             },
             messages: []
           }].to_json)

    expected = [{
      status: 'verified',
      original_address: {
        name: nil,
        company_name: nil,
        address_line1: '4 Jersey St.',
        address_line2: 'Suite 200',
        address_line3: '2nd Floor',
        phone: nil,
        city_locality: 'Boston',
        state_province: 'MA',
        postal_code: '02215',
        country_code: 'US',
        address_residential_indicator: 'unknown'
      },

      matched_address: {
        name: nil,
        company_name: nil,
        address_line1: '4 JERSEY ST STE 200',
        address_line2: '',
        address_line3: '2ND FLOOR',
        phone: nil,
        city_locality: 'BOSTON',
        state_province: 'MA',
        postal_code: '02215-4148',
        country_code: 'US',
        address_residential_indicator: 'no'
      },
      messages: []
    }]

    response = client.validate_addresses(params)
    assert_address_validation_result(expected[0], response[0])
    assert_requested(stub, times: 1)
  end

  it 'Validates a residential address' do
    params = [{
      name: 'John Smith',
      address_line1: '3910 Bailey Lane',
      city_locality: 'Austin',
      state_province: 'TX',
      postal_code: '78756',
      country_code: 'US',
      address_residential_indicator: true
    }]

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: params.to_json)
           .to_return(status: 200, body: [{
             status: 'verified',
             original_address: {
               name: 'John Smith',
               phone: nil,
               company_name: nil,
               address_line1: '3910 Bailey Lane',
               address_line2: nil,
               address_line3: nil,
               city_locality: 'Austin',
               state_province: 'TX',
               postal_code: '78756',
               country_code: 'US',
               address_residential_indicator: 'yes'
             },
             matched_address: {
               name: 'JOHN SMITH',
               phone: nil,
               company_name: nil,
               address_line1: '3910 BAILEY LN',
               address_line2: '',
               address_line3: nil,
               city_locality: 'AUSTIN',
               state_province: 'TX',
               postal_code: '78756-3924',
               country_code: 'US',
               address_residential_indicator: 'yes'
             },
             messages: []
           }].to_json)

    expected = [{
      status: 'verified',
      original_address: {
        name: 'John Smith',
        phone: nil,
        company_name: nil,
        address_line1: '3910 Bailey Lane',
        address_line2: nil,
        address_line3: nil,
        city_locality: 'Austin',
        state_province: 'TX',
        postal_code: '78756',
        country_code: 'US',
        address_residential_indicator: 'yes'
      },
      matched_address: {
        name: 'JOHN SMITH',
        phone: nil,
        company_name: nil,
        address_line1: '3910 BAILEY LN',
        address_line2: '',
        address_line3: nil,
        city_locality: 'AUSTIN',
        state_province: 'TX',
        postal_code: '78756-3924',
        country_code: 'US',
        address_residential_indicator: 'yes'
      },
      messages: []
    }]

    response = client.validate_addresses(params)
    assert_address_validation_result(expected[0], response[0])
    assert_requested(stub, times: 1)
  end

  it 'Validates an address with messages' do
    params = [{
      name: 'John Smith',
      address_line1: 'Winchester Blvd',
      city_locality: 'San Jose',
      state_province: 'CA',
      postal_code: '78756',
      country_code: 'US'
    }]

    stub = stub_request(:post, 'https://api.shipengine.com/v1/addresses/validate')
           .with(body: params.to_json)
           .to_return(status: 200, body: [{
             status: 'error',
             original_address: {
               name: 'John Smith',
               phone: nil,
               company_name: nil,
               address_line1: 'Winchester Blvd',
               address_line2: nil,
               address_line3: nil,
               city_locality: 'San Jose',
               state_province: 'CA',
               postal_code: '78756',
               country_code: 'US',
               address_residential_indicator: 'unknown'
             },
             matched_address: {
               name: 'JOHN SMITH',
               phone: nil,
               company_name: nil,
               address_line1: 'WINCHESTER BLVD',
               address_line2: '',
               address_line3: nil,
               city_locality: 'SAN JOSE',
               state_province: 'CA',
               postal_code: '95128-2092',
               country_code: 'US',
               address_residential_indicator: 'unknown'
             },
             messages: [
               {
                 code: 'a1004',
                 message: 'Address not found',
                 type: 'warning',
                 detail_code: nil
               },
               {
                 code: 'a1004',
                 message: 'Insufficient or Incorrect Address Data',
                 type: 'warning',
                 detail_code: nil
               }
             ]
           }].to_json)

    expected = [{
      status: 'error',
      original_address: {
        name: 'John Smith',
        phone: nil,
        company_name: nil,
        address_line1: 'Winchester Blvd',
        address_line2: nil,
        address_line3: nil,
        city_locality: 'San Jose',
        state_province: 'CA',
        postal_code: '78756',
        country_code: 'US',
        address_residential_indicator: 'unknown'
      },
      matched_address: {
        name: 'JOHN SMITH',
        phone: nil,
        company_name: nil,
        address_line1: 'WINCHESTER BLVD',
        address_line2: '',
        address_line3: nil,
        city_locality: 'SAN JOSE',
        state_province: 'CA',
        postal_code: '95128-2092',
        country_code: 'US',
        address_residential_indicator: 'unknown'
      },
      messages: [
        {
          code: 'a1004',
          message: 'Address not found',
          type: 'warning',
          detail_code: nil
        },
        {
          code: 'a1004',
          message: 'Insufficient or Incorrect Address Data',
          type: 'warning',
          detail_code: nil
        }
      ]
    }]

    response = client.validate_addresses(params)
    assert_address_validation_result(expected[0], response[0])
    assert_requested(stub, times: 1)
  end
end
