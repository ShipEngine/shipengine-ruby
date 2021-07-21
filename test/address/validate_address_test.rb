# frozen_string_literal: true

require "test_helper"
require "shipengine"
require "pry"

describe "Validate Address" do
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")
  it "Should successfully validate an address" do
    params = {
      address_line1: "501 Crawford St",
      city_locality: "Houston",
      postal_code: "77002",
      state_province: "TX",
      country_code: "US",
    }
    success_request = client.validate_address(params)
    assert success_request
  end

  ## The following confirms:
  # fields are correctly mapped from the server to the client (including isValid)
  # fields are the correct type
  # the response is an actual class
  #
  it "should serialize and coerce the address fields from the server into a ruby object with the correct shape" do
    params = {
      address_line1: "170 Warning Blvd",
      address_line2: "Apartment 32-B",
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country_code: "CA",
    }

    response = client.validate_address(params)

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
    assert_equal("error", response.status)
    assert_nil(response.matched_address)
  end

  it "should return name and company name and phone (if available)" do
    params = {
      name: "John Smith",
      phone: "77345517190",
      company: "Shipmate",
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country: "CA",
      address_line1: "123 Foo",
      address_line2: "Some Other Line",
    }

    response = client.validate_address(params)
    assert_equal("77345517190", response.original_address.phone)
    assert_equal("Shipmate", response.original_address.company)
    assert_equal("John Smith", response.original_address.name)
  end

  # # DX-1384
  # it "should work with no name, company, or phone" do
  #   params = {
  #     city_locality: "Toronto",
  #     state_province: "On",
  #     postal_code: "M6K 3C3",
  #     country: "CA",
  #     street: ["123 Foo", "Some Other Line"],
  #   }

  #   response = client.validate_address(params)
  #   assert_equal("", response.normalized_address.phone)
  #   assert_equal("", response.normalized_address.company)
  #   assert_equal("", response.normalized_address.name)
  # end
end
