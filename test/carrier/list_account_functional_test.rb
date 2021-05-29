# frozen_string_literal: true

require "test_helper"

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
  raise "Should have account_id / account_number" unless actual_carrier_account.account_id && actual_carrier_account.account_number

  assert_equal(expected[:account_id], actual_carrier_account.account_id, "~> account_id") if expected.key?(:account_id)

  assert_equal(expected[:account_number], actual_carrier_account.account_number, "~> account_number") if expected.key?(:account_number)
  return unless expected.key?(:carrier)

  expected_carrier = expected[:carrier]
  assert_equal(expected_carrier[:code], actual_carrier_account.carrier.code, "~> carrier.code")
  assert_equal(expected_carrier[:name], actual_carrier_account.carrier.name, "~> carrier.name")
end

describe "List Carrier Accounts: Functional" do
  client = ::ShipEngine::Client.new(api_key: "abc123")
  it "should have an optional argument of carrier_accounts" do
    expected = [
      {
        account_id: "car_1knseddGBrseWTiw",
        account_number: "1169350",
        name: "My UPS Account",
      },
    ]
    actual_response = client.list_carrier_accounts
    assert_list_carrier_response(expected, actual_response)

    actual_response2 = client.list_carrier_accounts(carrier_code: nil)
    assert_list_carrier_response(expected, actual_response2)
  end

  # DX-983
  it "handles a successful response" do
    expected = [
      {
        account_id: "car_1knseddGBrseWTiw",
        carrier: {
          code: "ups",
          name: "United Parcel Service",
        },
        account_number: "1169350",
        name: "My UPS Account",
      },
    ]
    actual_response = client.list_carrier_accounts(carrier_code: "ups")
    assert_list_carrier_response(expected, actual_response)
  end

  # DX-985 Multiple Carriers
  it "handles multiple carriers" do
    expected = [
      {
        account_id: "car_kfUjTZSEAQ8gHeT",
        carrier_code: "fedex",
        account_number: "41E-4928-29314AAX",
        name: "FedEx Account #1",
      },
      {
        account_id: "car_3a76b06902f812d14b33d6847",
        carrier_code: "fedex",
        account_number: "41E-4911-851657ABW",
        name: "FedEx Account #3",
      },
    ]

    actual_response = client.list_carrier_accounts(carrier_code: "fedex")

    assert_list_carrier_response(expected, actual_response)
  end

  # DX-984 No accounts setup yet
  it "handles if no accounts are setup" do
    expected = []

    actual_response = client.list_carrier_accounts(carrier_code: "purolator_canada")

    assert_list_carrier_response(expected, actual_response)
  end

  # DX-987
  it "handles an error with an invalid carrier code or other server error" do
    expected_err = {
      code: "invalid_field_value",
      request_id: :__REGEX_MATCH__,
    }
    assert_raises_shipengine(::ShipEngine::Exceptions::ValidationError, expected_err) do
      client.list_carrier_accounts(carrier_code: "I_DONT_EXIST")
    end

    expected_err = {
      code: "unspecified",
      request_id: :__REGEX_MATCH__,
    }
    assert_raises_shipengine(::ShipEngine::Exceptions::SystemError, expected_err) do
      client.list_carrier_accounts(carrier_code: "access_worldwide")
    end
  end
end
