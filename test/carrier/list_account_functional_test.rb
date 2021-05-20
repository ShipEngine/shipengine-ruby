require 'test_helper'
require 'shipengine'
require 'json'

#
# <Description>
#
# @param expected_arr [Array<Hash>]
# @param response_arr [Array<::ShipEngine::CarrierAccount>]
def assert_list_carrier_response(expected, actual_response)
  expected.each_with_index do |carrier_account, idx|
    assert_carrier_account(carrier_account, actual_response[idx])
  end
end

# @param expected [Hash]
# @param response [::ShipEngine::CarrierAccount]
# @return [<Type>] <description>
def assert_carrier_account(expected, actual_carrier_account)
  raise 'Should have account_id / account_number' unless actual_carrier_account.account_id && actual_carrier_account.account_number

  assert_equal(expected[:account_id], actual_carrier_account.account_id, '~> account_id') if expected.key?(:account_id)

  assert_equal(expected[:account_number], actual_carrier_account.account_number, '~> account_number') if expected.key?(:account_number)
  if expected.key?(:carrier)
    expected_carrier = expected[:carrier]
    assert_equal(expected_carrier[:code], actual_carrier_account.carrier.code, '~> carrier.code')
    assert_equal(expected_carrier[:name], actual_carrier_account.carrier.name, '~> carrier.name')
  end
end

describe 'List Carrier Accounts: Functional' do
  client = ::ShipEngine::Client.new(api_key: 'abc123')
  it 'handles an error with an invalid carrier code' do
    expected_err = {
      source: 'shipengine',
      type: 'validation',
      code: 'invalid_field_value',
      request_id: :__REGEX_MATCH__
    }
    assert_raises_shipengine(::ShipEngine::Exceptions::ShipEngineError, expected_err) do
      client.list_carrier_accounts(carrier_code: 'Foo')
    end
  end

  it 'handles a success' do
    expected = [
      {
        account_id: 'car_1knseddGBrseWTiw',
        carrier: {
          code: 'ups',
          name: 'United Parcel Service'
        },
        account_number: '1169350',
        name: 'My UPS Account'
      }
    ]
    actual_response = client.list_carrier_accounts(carrier_code: 'ups')
    assert_list_carrier_response(expected, actual_response)
  end
end
