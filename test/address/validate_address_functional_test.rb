# frozen_string_literal: true

require 'test_helper'
require 'shipengine'

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
  client = ::ShipEngine::Client.new(api_key: 'abc123')
  # DX-936 Multi-line address returned correctly
  it 'should work with multi-line street addresses' do
    response = client.validate_address(get_address)
    assert_equal(['123 Foo', 'Some Other Line'], response.normalized_address.street)
  end

  # DX-943 too many address lines
  it 'should throw a client-side error if there are too many address lines' do
    expected = {
      code: :invalid_field_value,
      message: 'Invalid address. No more than 3 street lines are allowed.'
    }
    assert_raises_shipengine_validation(expected) do
      street = %w[this should throw error]
      client.validate_address(get_address(street: street))
    end
  end

  # https://github.com/ShipEngine/shipengine-js/blob/main/test/specs/validate-address.spec.js
  # DX-942 No Address Lines
  it 'should throw a client-side error if there are no address lines' do
    expected = {
      code: :invalid_field_value,
      message: 'Invalid address. At least one address line is required.'
    }
    assert_raises_shipengine_validation(expected) do
      client.validate_address(get_address({ street: [] }))
    end
  end

  def assert_address_equals(expected_address, response)
    assert_equal(expected_address[:valid], response.valid?, '-> valid')
    assert_equal(expected_address[:normalized_address][:residential], response.normalized_address.residential?, '-> residential')
    assert_equal(expected_address[:normalized_address][:name], response.normalized_address.name, '-> name')
    assert_equal(expected_address[:normalized_address][:company], response.normalized_address.company, '-> company')
    assert_equal(expected_address[:normalized_address][:phone], response.normalized_address.phone, '-> phone')
    assert_equal(expected_address[:normalized_address][:street], response.normalized_address.street, '-> street')
    assert_equal(expected_address[:normalized_address][:city_locality], response.normalized_address.city_locality, '-> city_locality')
    assert_equal(expected_address[:normalized_address][:country], response.normalized_address.country, '-> country')
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
end
