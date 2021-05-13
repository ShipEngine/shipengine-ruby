# frozen_string_literal: true

require 'test_helper'
require 'shipengine'

exceptions = ::ShipEngine::Exceptions

describe 'Validate Address' do
  #
  # <Description>
  #
  # @param [Hash] err_hash
  # @param [class] err_res
  #

  client = ::ShipEngine::Client.new(api_key: 'abc123')
  it 'Should successfully validate an address' do
    success_request = client.validate_address({
                                                street: ['501 Crawford St'],
                                                city_locality: 'Houston',
                                                postal_code: '77002',
                                                state_province: 'TX',
                                                country: 'US'
                                              })
    assert success_request
  end

  it 'should propgate server errors if server response has error' do
    err = assert_raises exceptions::ValidationError do
      client.validate_address({
                                street: nil,
                                city_locality: 'Houston',
                                postal_code: '77002',
                                state_province: 'TX',
                                country: nil
                              })
    end
    assert_response_error(err,
                          { code: exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED),
                            source: 'shipengine',
                            type: 'validation' })
  end

  ## The following confirms:
  # fields are correctly mapped from the server to the client (including isValid)
  # fields are the correct type
  # the response is an actual class
  #
  it 'should serialize and coerce the address fields from the server into a ruby object with the correct shape' do
    address_params = {
      street: [
        '170 Warning Blvd',
        'Apartment 32-B'
      ],
      city_locality: 'Toronto',
      state_province: 'On',
      postal_code: 'M6K 3C3',
      country: 'CA'
    }

    response = client.validate_address(address_params)

    # Expected api response:
    # _address_result = {
    #   isValid: true,
    #   normalizedAddress: {
    #     street: [
    #       '170 Warning Blvd Apt 32-B'
    #     ],
    #     cityLocality: 'Toronto',
    #     stateProvince: 'On',
    #     postalCode: 'M6K 3C3',
    #     countryCode: 'CA',
    #     isResidential: true
    #   },
    #   messages: [
    #     {
    #       type: 'warning',
    #       code: 'partially_verified_to_premise_level',
    #       message: 'This address has been verified down to the house/building level (highest possible accuracy with the provided data)'
    #     }
    #   ]
    # }
    assert_equal(true, response.valid?)
    assert_nil(response.normalized_address.name)
    assert_nil(response.normalized_address.company)
    assert_nil(response.normalized_address.phone)
    assert_equal(['170 Warning Blvd Apt 32-B'], response.normalized_address.street)
    assert_equal('Toronto', response.normalized_address.city_locality)
    assert_equal(true, response.normalized_address.residential?)
    assert_equal('CA', response.normalized_address.country)
  end

  it 'should work with multi-line street and return them in the correct order' do
    address_to_validate = {
      name: 'John Smith',
      company: 'ShipMate',
      city_locality: 'Toronto',
      state_province: 'On',
      postal_code: 'M6K 3C3',
      country: 'CA',
      street: ['123 Foo', 'Some Other Line']
    }

    response = client.validate_address(address_to_validate)
    assert_equal(['123 Foo', 'Some Other Line'], response.normalized_address.street)
  end

  it 'should return name and company name and phone (if available)' do
    # Address to validate
    address_to_validate = {
      name: 'John Smith',
      phone: '77345517190',
      company: 'Shipmate',
      city_locality: 'Toronto',
      state_province: 'On',
      postal_code: 'M6K 3C3',
      country: 'CA',
      street: ['123 Foo', 'Some Other Line']
    }

    response = client.validate_address(address_to_validate)
    assert_equal('77345517190', response.normalized_address.phone)
    assert_equal('Shipmate', response.normalized_address.company)
    assert_equal('John Smith', response.normalized_address.name)
  end
end
