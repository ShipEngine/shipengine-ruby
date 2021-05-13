# frozen_string_literal: true

require 'test_helper'
require 'shipengine'
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
# @param expected_address [Hash]
# @param response [::ShipEngine::AddressValidationResult]
def assert_address_equals(expected_address, response)
  # rubocop:disable Layout/LineLength
  assert_equal(expected_address[:valid], response.valid?, '-> valid') if expected_address.key?(:valid)
  assert_messages_equals(expected_address[:warnings], response.warnings) if expected_address.key?(:warnings)
  assert_messages_equals(expected_address[:info], response.info) if expected_address.key?(:info)
  assert_messages_equals(expected_address[:errors], response.errors) if expected_address.key?(:errors)

  expected_address_normalized = expected_address[:normalized_address] || {}
  assert_equal(expected_address_normalized[:residential], response.normalized_address.residential?, '-> residential') if expected_address_normalized.key?(:residential)
  assert_equal(expected_address_normalized[:name], response.normalized_address.name, '-> name') if expected_address_normalized.key?(:name)
  assert_equal(expected_address_normalized[:company], response.normalized_address.company, '-> company') if expected_address_normalized.key?(:company)
  assert_equal(expected_address_normalized[:phone], response.normalized_address.phone, '-> phone')  if expected_address_normalized.key?(:phone)
  assert_equal(expected_address_normalized[:street], response.normalized_address.street, '-> street') if expected_address_normalized.key?(:street)
  assert_equal(expected_address_normalized[:city_locality], response.normalized_address.city_locality, '-> city_locality') if expected_address_normalized.key?(:city_locality)
  assert_equal(expected_address_normalized[:country], response.normalized_address.country, '-> country') if expected_address_normalized.key?(:country)
  # rubocop:disable Layout/LineLength
end

# @param expected_messages [Array<Hash>]
# @param response_messages [Array<::ShipEngine::AddressValidationMessage>]
def assert_messages_equals(expected_messages, response_messages)
  assert_equal(expected_messages.length, response_messages.length,
               "expected_messages and response_messages should be the same length. expected: #{expected_messages}, response: #{response_messages}")
  expected_messages.each_with_index do |message, idx|
    r_msg = response_messages[idx]
    assert_equal(message[:code], r_msg.code)
    assert_equal(message[:type], r_msg.type)
    assert_equal(message[:message], r_msg.message)
  end
end

describe 'Validate Address: Functional' do
  client = ::ShipEngine::Client.new(api_key: 'abc123')
  # DX-936 Multi-line address returned correctly
  it 'should work with multi-line street addresses' do
    params = {
      country: 'US',
      street: ['4 Jersey St.', 'Suite 200', '2nd Floor'],
      city_locality: 'Boston',
      state_province: 'MA',
      postal_code: '02215'
    }
    expected = {
      valid: true,
      warnings: [],
      errors: [],
      info: [],
      normalized_address: {
        residential: false,
        country: 'US',
        street: ['4 JERSEY ST STE 200', '2ND FLOOR'],
        city_locality: 'BOSTON',
        state_province: 'MA',
        postal_code: '02215',
        name: '',
        phone: '',
        company: ''
      }
    }
    response = client.validate_address(params)
    assert_address_equals(expected, response)
  end

  # DX-943 too many address lines
  it 'should throw a client-side error if there are too many address lines' do
    expected = {
      code: :invalid_field_value,
      message: 'Invalid address. No more than 3 street lines are allowed.'
    }
    assert_raises_shipengine_validation(expected) do
      client.validate_address(get_address(street: %w[this should throw error]))
    end
  end

  # https://github.com/ShipEngine/shipengine-js/blob/main/test/specs/validate-address.spec.js
  # DX-942 No Address Lines
  it 'should throw a client-side error if there are no address lines' do
    expected = {
      code: :field_value_required,
      message: 'Invalid address. At least one address line is required.'
    }

    params = get_address({ street: [] })
    assert_raises_shipengine_validation(expected) do
      client.validate_address(params)
    end
  end

  # DX-935 Valid Residential
  it 'should handle residential' do
    params = {
      country: 'US',
      street: ['4 Jersey St', 'Apt. 2b'],
      city_locality: 'Boston',
      state_province: 'MA',
      postal_code: '02215'
    }

    expected = {
      valid: true,
      normalized_address: {
        residential: true,
        country: 'US',
        street: ['4 JERSEY ST APT 2B'],
        city_locality: 'BOSTON',
        state_province: 'MA',
        postal_code: '02215',
        phone: '',
        name: '',
        company: ''
      }
    }

    response = client.validate_address(params)
    assert_address_equals(expected, response)
  end

  # DX-935 Valid Commercial
  it 'should handle commercial' do
    params = {
      country: 'US',
      street: ['400 Jersey St'],
      city_locality: 'Boston',
      state_province: 'MA',
      postal_code: '02215'
    }

    expected = {
      valid: true,
      normalized_address: {
        residential: false,
        country: 'US',
        street: ['400 JERSEY ST'],
        city_locality: 'BOSTON',
        state_province: 'MA',
        postal_code: '02215',
        name: '',
        phone: '',
        company: ''
      }
    }
    response = client.validate_address(params)
    assert_address_equals(expected, response)
  end

  # DX-935 Valid address of unknown type
  it 'should handle unknown' do
    response = client.validate_address(get_address)
    assert_equal(['123 Foo', 'Some Other Line'], response.normalized_address.street)
  end
  # DX-947
  it 'handles server-side errors' do


  end

  # DX-944
  it 'handles missing city+state or postal code' do
    missing_postal_code_or_city = {
      country: "US",
      street: ["123 Some St."],
      state_province: "TX"
    };

    missing_postal_code_or_state = {
      country: "US",
      street: ["123 Some St."],
      city_locality: "Austin"
    }

    missing_postal_code_city_and_state = {
      country: "US",
      street: ["123 Some St."]
    }

    expected = {
      code: :field_value_required,
      message:
        "Invalid address. Either the postal code or the city/locality and state/province must be specified.",
    }

    assert_raises_shipengine_validation(expected) do
      client.validate_address(missing_postal_code_or_city)
    end

    assert_raises_shipengine_validation(expected) do
      client.validate_address(missing_postal_code_or_state)
    end

    assert_raises_shipengine_validation(expected) do
      client.validate_address(missing_postal_code_city_and_state)
    end
    # nice
  end


  # DX-937
  it 'handles numeric postal code' do
  end

  # DX-941
  it 'handles messages: error' do
     params = {
      street: ["170 Invalid Blvd"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country: "CA",
    };
    response = client.validate_address(params)
    expected_warning_message = {
      code: "address_not_found",
      message: "Address not found",
      type: "warning",
    };

    expected_error_message = {
      code: "address_not_found",
      message: "Invalid City, State, or Zip",
      type: "error",
    };

    expected_error_message2 = {
      code: "address_not_found",
      message: "Insufficient or Incorrect Address Data",
      type: "error",
    };

    expected = {
      normalized_address: nil,
      errors: [expected_error_message, expected_error_message2],
      warnings: [expected_warning_message]
    }
    assert_address_equals(expected, response)
    # nice
  end

  # DX-940
  it 'handles messages: warning' do
    params = {
      street: ['170 Warning Blvd', 'Apartment 32-B'],
      city_locality: 'Toronto',
      state_province: 'On',
      postal_code: 'M6K 3C3',
      country: 'CA'
    }

    expected_warning_message = {
      type: 'warning',
      code: 'partially_verified_to_premise_level',
      message:
        'This address has been verified down to the house/building level (highest possible accuracy with the provided data)'
    }

    expected = {
      valid: true,
      normalized_address: {
        residential: true,
        street: ['170 Warning Blvd Apt 32-B'],
        city_locality: 'Toronto',
        state_province: 'On',
        postal_code: 'M6K 3C3',
        country: 'CA',
      },
      warnings: [expected_warning_message],
      info: [],
      errors: [],
    }

    response = client.validate_address(params)
    assert_address_equals(expected, response)
  end

  # DX-939
  it 'handles non-latin characters' do
  end

  # DX-938
  it 'handles alpha postal code' do
  end


end
