# frozen_string_literal: true

require "test_helper"
require "json"
require "pry"

def get_address(overrides = {})
  {
    name: "John Smith",
    company: "ShipMate",
    city_locality: "Toronto",
    state_province: "On",
    postal_code: "M6K 3C3",
    country: "CA",
    street: ["123 Foo", "Some Other Line"],
  }.merge(overrides)
end

describe "Validate Address: Functional" do
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  # DX-938 -
  it "handles unauthorized errors" do
    invalid_client = ::ShipEngine::Client.new("abc123")
    params = [{
      address_line1: "500 Server Error",
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "01152",
      country: "US",
    }]
    expected_err = {
      source: "shipengine",
      type: "security",
      code: "unauthorized",
      message: "The API key is invalid. Please see https://www.shipengine.com/docs/auth",
    }

    assert_raises_shipengine(::ShipEngine::Exceptions::ShipEngineError, expected_err) do
      invalid_client.validate_addresses(params)
    end
  end

  # DX-936 Multi-line address returned correctly
  it "should work with multi-line street addresses" do
    params = [{
      country_code: "US",
      address_line1: "4 Jersey St.",
      address_line2: "Suite 200",
      address_line3: "2nd Floor",
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
    }]

    expected = {
      status: "verified",
      original_address: { name: nil, company_name: nil, address_line1: "4 Jersey St.", address_line2: "Suite 200", address_line3: "2nd Floor",
                          phone: nil, city_locality: "Boston", state_province: "MA", postal_code: "02215", country_code: "US",
                          address_residential_indicator: "unknown" },
      matched_address: { name: nil, company_name: nil, address_line1: "4 JERSEY ST STE 200", address_line2: "", address_line3: "2ND FLOOR",
                         phone: nil, city_locality: "BOSTON", state_province: "MA", postal_code: "02215-4148", country_code: "US",
                         address_residential_indicator: "no" },
      messages: [],
    }
    response = client.validate_addresses(params)
    assert_address_validation_result(expected, response[0])
  end

  #   # DX-939
  it "handles non-latin characters" do
    params = [{
      address_line1: "上鳥羽角田町６８",
      city_locality: "南区",
      state_province: "京都",
      postal_code: "601-8104",
      country_code: "JP",
    }]

    expected = {
      status: "verified",
      original_address: { name: nil, company_name: nil, address_line1: "上鳥羽角田町６８", address_line2: nil, address_line3: nil, phone: nil,
                          city_locality: "南区", state_province: "京都", postal_code: "601-8104", country_code: "JP",
                          address_residential_indicator: "unknown" },
      matched_address: { name: nil, company_name: "", address_line1: "68 Kamitobatsunodacho", address_line2: "", address_line3: "", phone: nil,
                         city_locality: "Kyoto-Shi Minami-Ku", state_province: "Kyoto", postal_code: "601-8104", country_code: "JP",
                         address_residential_indicator: "unknown" },
      messages: [{ type: "warning", code: "a1003", message: "There was a change or addition to the state/province." },
                 { type: "info", code: "a1007",
                   message: "This address has been verified down to the house/building level (highest possible accuracy with the provided data)" },
                 { type: "info", code: "a1008",
                   message: "This record was successfully geocoded down to the rooftop level, meaning this point is within the property limits (most likely in the center)." }],
    }

    response = client.validate_addresses(params)
    assert_address_validation_result(expected, response[0])
  end
end
