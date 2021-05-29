# frozen_string_literal: true

require "test_helper"
require "shipengine"
require "json"

describe "Normalize Address: Functional" do
  # https://github.com/ShipEngine/shipengine-js/blob/main/test/specs/normalize-address.spec.js
  client = ::ShipEngine::Client.new(api_key: "abc123")
  # DX-965
  it "handles server-side errors" do
    params = {
      street: ["500 Server Error"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "01152",
      country: "US",
    }
    expected_err = {
      source: "shipengine",
      type: "system",
      code: "unspecified",
      message: "Unable to connect to the database",
      request_id: :__REGEX_MATCH__,
    }
    assert_raises_shipengine(::ShipEngine::Exceptions::ShipEngineError, expected_err) do
      client.normalize_address(params)
    end
  end

  # 953
  it "should work with multi-line street addresses" do
    params = {
      country: "US",
      street: ["4 Jersey St.", "Suite 200", "2nd Floor"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
      request_id: :__REGEX_MATCH__,
    }
    expected = {
      residential: false,
      country: "US",
      street: ["4 JERSEY ST STE 200", "2ND FLOOR"],
      city_locality: "BOSTON",
      state_province: "MA",
      postal_code: "02215",
      name: "",
      phone: "",
      company: "",
    }
    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end

  it "should throw a client-side error if there are too many address lines" do
    expected = {
      code: "invalid_field_value",
      message: "Invalid address. No more than 3 street lines are allowed.",
      request_id: nil,
    }
    assert_raises_shipengine_validation(expected) do
      client.normalize_address(get_address(street: ["this", "should", "throw", "error"]))
    end
  end

  it "should throw a client-side error if there are no address lines" do
    expected = {
      code: "field_value_required",
      message: "Invalid address. At least one address line is required.",
      request_id: nil,
    }

    params = get_address({ street: [] })
    assert_raises_shipengine_validation(expected) do
      client.normalize_address(params)
    end
  end

  # DX-950
  it "should handle residential" do
    params = {
      country: "US",
      street: ["4 Jersey St", "Apt. 2b"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
    }

    expected = {
      residential: true,
      country: "US",
      street: ["4 JERSEY ST APT 2B"],
      city_locality: "BOSTON",
      state_province: "MA",
      postal_code: "02215",
      phone: "",
      name: "",
      company: "",
    }
    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end

  it "should handle commercial" do
    params = {
      country: "US",
      street: ["400 Jersey St"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
    }

    expected = {
      residential: false,
      country: "US",
      street: ["400 JERSEY ST"],
      city_locality: "BOSTON",
      state_province: "MA",
      postal_code: "02215",
      name: "",
      phone: "",
      company: "",
    }
    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end

  # 952
  it "should handle unknown" do
    params = {
      country: "US",
      street: ["4 Jersey St"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
    }

    expected = {
      country: "US",
      street: ["4 JERSEY ST"],
      city_locality: "BOSTON",
      state_province: "MA",
      postal_code: "02215",
      name: "",
      company: "",
    }
    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end

  # 956
  it "handles non-latin characters" do
    params = {
      street: ["上鳥羽角田町６８", "normalize-with-non-latin-chars"],
      city_locality: "南区",
      state_province: "京都",
      postal_code: "601-8104",
      country: "JP",
    }

    expected = {
      street: ["68 Kamitobatsunodacho"],
      city_locality: "Kyoto-Shi Minami-Ku",
      state_province: "Kyoto",
      postal_code: "601-8104",
      country: "JP",
    }

    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end

  # DX-964 / 963
  it "normalizes country code / missing country-code" do
    # missing
    assert_raises_shipengine_validation({
      code: ::ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED),
      message: "Invalid address. The country must be specified.",
    }) do
      client.normalize_address({
        street: ["400 Jersey St"],
        city_locality: "Boston",
        state_province: "MA",
        postal_code: "02215",
      })
    end

    assert_raises_shipengine_validation({
      code: "invalid_field_value",
      message: "Invalid address. XX is not a valid country code.",
    }) do
      client.normalize_address({
        country: "XX",
        street: ["400 Jersey St"],
        city_locality: "Boston",
        state_province: "MA",
        postal_code: "02215",
      })
    end
  end

  it "handles missing city+state or postal code" do
    # CLIENT-SIDE
    missing_postal_code_or_city = {
      country: "US",
      street: ["123 Some St."],
      state_province: "TX",
    }

    missing_postal_code_or_state = {
      country: "US",
      street: ["123 Some St."],
      city_locality: "Austin",
    }

    missing_postal_code_city_and_state = {
      country: "US",
      street: ["123 Some St."],
    }

    expected_err = {
      code: "field_value_required",
      message:
        "Invalid address. Either the postal code or the city/locality and state/province must be specified.",
    }

    assert_raises_shipengine_validation(expected_err) do
      client.normalize_address(missing_postal_code_or_city)
    end

    assert_raises_shipengine_validation(expected_err) do
      client.normalize_address(missing_postal_code_or_state)
    end

    assert_raises_shipengine_validation(expected_err) do
      client.normalize_address(missing_postal_code_city_and_state)
    end
  end

  # 954
  it "handles numeric postal code " do
    params = {
      country: "US",
      street: ["4 Jersey St"],
      city_locality: "Boston",
      state_province: "MA",
      postal_code: "02215",
    }

    response = client.normalize_address(params)
    expected = {
      country: "US",
      street: ["4 JERSEY ST"],
      city_locality: "BOSTON",
      state_province: "MA",
      postal_code: "02215",
      name: "",
      company: "",
    }
    assert_normalized_address(expected, response)
  end

  # 955
  it "handles alphanumeric postal code " do
    params = {
      country: "CA",
      street: ["170 Princes' Blvd"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
    }
    response = client.normalize_address(params)
    expected = {
      country: "CA",
      street: ["170 Princes Blvd"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6 K 3 C3",
    }
    assert_normalized_address(expected, response)
  end

  # 958
  it "Throws an error with one error message" do
    params = {
      country: "CA",
      street: ["170 Error Blvd"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
    }

    expected = {
      source: "shipengine",
      type: "business_rules",
      code: "invalid_address",
      message: "Invalid Address. Insufficient or inaccurate postal code",
      request_id: :__REGEX_MATCH__,
    }

    assert_raises_shipengine(ShipEngine::Exceptions::ShipEngineError, expected) do
      client.normalize_address(params)
    end
  end

  # 959
  it "Should handle multiple merror messages" do
    params = {
      street: ["170 Invalid Blvd"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country: "CA",
    }

    assert_raises_shipengine(::ShipEngine::Exceptions::ShipEngineError, {
      code: "invalid_address",
                               message: "Invalid Address. Invalid City, State, or Zip\nInsufficient or Incorrect Address Data",
    }) do
      client.normalize_address(params)
    end
  end
  # 957
  it "handles messages: warnings" do
    params = {
      street: ["170 Warning Blvd", "Apartment 32-B"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country: "CA",
    }

    expected = {
      residential: true,
      street: ["170 Warning Blvd Apt 32-B"],
      city_locality: "Toronto",
      state_province: "On",
      postal_code: "M6K 3C3",
      country: "CA",
    }

    response = client.normalize_address(params)
    assert_normalized_address(expected, response)
  end
end
