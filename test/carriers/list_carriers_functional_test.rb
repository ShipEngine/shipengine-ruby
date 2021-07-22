# frozen_string_literal: true

require "test_helper"
require "pry"

#
# <Description>
#
# @param expected_arr [Hash]
def assert_list_carrier_response(expected, actual_response)
  assert_equal(expected[:carriers].length, actual_response.carriers.length) if expected.key?(:carriers)
  assert_equal(expected[:request_id], actual_response.request_id) if expected.key?(:request_id)

  expected[:carriers].each_with_index do |carrier_account, idx|
    assert_carrier_account(carrier_account, actual_response.carriers[idx])
  end

  expected[:errors].each_with_index do |error, idx|
    assert_error(error, actual_response.errors[idx])
  end
end

def assert_error(expected, actual_error)
  assert_equal(expected[:error_source], actual_error.error_source) if expected.key?(:error_source)
  assert_equal(expected[:error_type], actual_error.error_type) if expected.key?(:error_type)
  assert_equal(expected[:error_code], actual_error.error_code) if expected.key?(:error_code)
  assert_equal(expected[:message], actual_error.message) if expected.key?(:message)
end

# @param expected [Hash]
# @param response [::ShipEngine::CarrierAccount]
# @return [<Type>] <description>
def assert_carrier_account(expected, actual_carrier)
  assert_equal(expected[:carrier_id], actual_carrier.carrier_id) if expected.key?(:carrier_id)
  assert_equal(expected[:carrier_code], actual_carrier.carrier_code) if expected.key?(:carrier_code)
  assert_equal(expected[:account_number], actual_carrier.account_number) if expected.key?(:account_number)
  assert_equal(expected[:requires_funded_amount], actual_carrier.requires_funded_amount) if expected.key?(:requires_funded_amount)
  assert_equal(expected[:balance], actual_carrier.balance) if expected.key?(:balance)
  assert_equal(expected[:nickname], actual_carrier.nickname) if expected.key?(:nickname)
  assert_equal(expected[:friendly_name], actual_carrier.friendly_name) if expected.key?(:friendly_name)
  assert_equal(expected[:primary], actual_carrier.primary) if expected.key?(:primary)

  expected[:services].each_with_index do |service, idx|
    assert_service(service, actual_carrier.services[idx])
  end

  expected[:options].each_with_index do |option, idx|
    assert_option(option, actual_carrier.options[idx])
  end

  expected[:packages].each_with_index do |package, idx|
    assert_package(package, actual_carrier.packages[idx])
  end
end

def assert_package(expected, actual_package)
  assert_equal(expected[:package_id], actual_package.package_id) if expected.key?(:package_id)
  assert_equal(expected[:package_code], actual_package.package_code) if expected.key?(:package_code)
  assert_equal(expected[:name], actual_package.name) if expected.key?(:name)
  assert_equal(expected[:description], actual_package.description) if expected.key?(:description)
  assert_equal(expected[:dimensions][:unit], actual_package.dimensions.unit) if expected.key?(:dimensions)
  assert_equal(expected[:dimensions][:length], actual_package.dimensions.length) if expected.key?(:dimensions)
  assert_equal(expected[:dimensions][:width], actual_package.dimensions.width) if expected.key?(:dimensions)
  assert_equal(expected[:dimensions][:height], actual_package.dimensions.height) if expected.key?(:dimensions)
end

def assert_service(expected, actual_service)
  assert_equal(expected[:carrier_id], actual_service.carrier_id) if expected.key?(:carrier_id)
  assert_equal(expected[:carrier_code], actual_service.carrier_code) if expected.key?(:carrier_code)
  assert_equal(expected[:service_code], actual_service.service_code) if expected.key?(:service_code)
  assert_equal(expected[:name], actual_service.name) if expected.key?(:name)
  assert_equal(expected[:domestic], actual_service.domestic) if expected.key?(:domestic)
  assert_equal(expected[:international], actual_service.international) if expected.key?(:international)
  assert_equal(expected[:is_multi_package_supported], actual_service.is_multi_package_supported) if expected.key?(:is_multi_package_supported)
end

def assert_option(expected, actual_option)
  assert_equal(expected[:name], actual_option.name) if expected.key?(:name)
  assert_equal(expected[:default_value], actual_option.default_value) if expected.key?(:default_value)
  assert_equal(expected[:description], actual_option.description) if expected.key?(:description)
end

describe "List Carrier Accounts: Functional" do
  after do
    WebMock.reset!
  end
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  it "handles unauthorized errors" do
    stub = stub_request(:get, "https://api.shipengine.com/v1/carriers")
      .to_return(status: 401, body: {
        "request_id" => "cdc19c7b-eec7-4730-8814-462623a62ddb",
        "errors" => [{
          "error_source" => "shipengine",
          "error_type" => "security",
          "error_code" => "unauthorized",
          "message" => "The API key is invalid. Please see https://www.shipengine.com/docs/auth",
        }],
      }.to_json)

    expected_err = {
      source: "shipengine",
      type: "security",
      code: "unauthorized",
      message: "The API key is invalid. Please see https://www.shipengine.com/docs/auth",
    }

    assert_raises_shipengine(::ShipEngine::Exceptions::ShipEngineError, expected_err) do
      client.list_carriers
      assert_requested(stub, times: 1)
    end
  end

  it "handles a successful response with multiple carriers" do
    stub = stub_request(:get, "https://api.shipengine.com/v1/carriers")
      .to_return(status: 200, body: {
        "carriers": [
          {
            "carrier_id": "se-28529731",
            "carrier_code": "se-28529731",
            "account_number": "account_570827",
            "requires_funded_amount": true,
            "balance": 3799.52,
            "nickname": "ShipEngine Account - Stamps.com",
            "friendly_name": "Stamps.com",
            "primary": true,
            "has_multi_package_supporting_services": true,
            "supports_label_messages": true,
            "services": [
              {
                "carrier_id": "se-28529731",
                "carrier_code": "se-28529731",
                "service_code": "usps_media_mail",
                "name": "USPS First Class Mail",
                "domestic": true,
                "international": true,
                "is_multi_package_supported": true,
              },
            ],
            "packages": [
              {
                "package_id": "se-28529731",
                "package_code": "small_flat_rate_box",
                "name": "laptop_box",
                "dimensions": {
                  "unit": "inch",
                  "length": 1,
                  "width": 1,
                  "height": 1,
                },
                "description": "Packaging for laptops",
              },
            ],
            "options": [
              {
                "name": "contains_alcohol",
                "default_value": "false",
                "description": "string",
              },
            ],
          },
          {
            "carrier_id": "se-test",
            "carrier_code": "se-testing",
            "account_number": "account_117",
            "requires_funded_amount": true,
            "balance": 3799.12,
            "nickname": "ShipEngine Account 2",
            "friendly_name": "Stamps.com 2",
            "primary": false,
            "has_multi_package_supporting_services": false,
            "supports_label_messages": false,
            "services": [
              {
                "carrier_id": "se-test",
                "carrier_code": "se-test",
                "service_code": "usps_media_mail+test",
                "name": "USPS First Class Mail test",
                "domestic": false,
                "international": false,
                "is_multi_package_supported": false,
              },
            ],
            "packages": [
              {
                "package_id": "se-28529731",
                "package_code": "+small_flat_rate_box",
                "name": "laptop_box+test",
                "dimensions": {
                  "unit": "centimeters",
                  "length": 4,
                  "width": 1,
                  "height": 1,
                },
                "description": "Packaging for laptops",
              },
            ],
            "options": [
              {
                "name": "contains_alcohol",
                "default_value": "false",
                "description": "string",
              },
            ],
          },
        ],
        "request_id": "aa3d8e8e-462b-4476-9618-72db7f7b7009",
        "errors": [
          {
            "error_source": "carrier",
            "error_type": "account_status",
            "error_code": "auto_fund_not_supported",
            "message": "Body of request cannot be null.",
          },
        ],
      }.to_json)

    expected = {
      carriers: [
        {
          carrier_id: "se-28529731",
          carrier_code: "se-28529731",
          account_number: "account_570827",
          requires_funded_amount: true,
          balance: 3799.52,
          nickname: "ShipEngine Account - Stamps.com",
          friendly_name: "Stamps.com",
          primary: true,
          has_multi_package_supporting_services: true,
          supports_label_messages: true,
          services: [
            {
              carrier_id: "se-28529731",
              carrier_code: "se-28529731",
              service_code: "usps_media_mail",
              name: "USPS First Class Mail",
              domestic: true,
              international: true,
              is_multi_package_supported: true,
            },
          ],
          packages: [
            {
              package_id: "se-28529731",
              package_code: "small_flat_rate_box",
              name: "laptop_box",
              dimensions: {
                unit: "inch",
                length: 1,
                width: 1,
                height: 1,
              },
              description: "Packaging for laptops",
            },
          ],
          options: [
            {
              name: "contains_alcohol",
              default_value: "false",
              description: "string",
            },
          ],
        },
        {
          carrier_id: "se-test",
          carrier_code: "se-testing",
          account_number: "account_117",
          requires_funded_amount: true,
          balance: 3799.12,
          nickname: "ShipEngine Account 2",
          friendly_name: "Stamps.com 2",
          primary: false,
          has_multi_package_supporting_services: false,
          supports_label_messages: false,
          services: [
            {
              carrier_id: "se-test",
              carrier_code: "se-test",
              service_code: "usps_media_mail+test",
              name: "USPS First Class Mail test",
              domestic: false,
              international: false,
              is_multi_package_supported: false,
            },
          ],
          packages: [
            {
              package_id: "se-28529731",
              package_code: "+small_flat_rate_box",
              name: "laptop_box+test",
              dimensions: {
                unit: "centimeters",
                length: 4,
                width: 1,
                height: 1,
              },
              description: "Packaging for laptops",
            },
          ],
          options: [
            {
              name: "contains_alcohol",
              default_value: "false",
              description: "string",
            },
          ],
        },
      ],
      request_id: "aa3d8e8e-462b-4476-9618-72db7f7b7009",
      errors: [
        {
          error_source: "carrier",
          error_type: "account_status",
          error_code: "auto_fund_not_supported",
          message: "Body of request cannot be null.",
        },
      ],
    }

    actual_response = client.list_carriers
    assert_list_carrier_response(expected, actual_response)
    assert_requested(stub, times: 1)
  end
end
