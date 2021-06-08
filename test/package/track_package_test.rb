# frozen_string_literal: true

require "test_helper"

describe "track package" do
  it "DX-993 Tracks a package using a tracking number and carrier code" do
    tracking_number_valid = "aaaaa_delivered"
    carrier_code_valid = "fedex"

    client = ::ShipEngine::Client.new("abc1234")

    # The tracking number that's returned matches the tracking number that was specified
    result = client.track_package_by_tracking_number(tracking_number_valid, carrier_code_valid)
    p result
    assert_equal(tracking_number_valid, result.package.tracking_number, "The carrier that's returned matches the carrier code that was specified")

    # # The carrier that's returned matches the carrier code that was specified
    assert(result.shipment, "shipment should exist")
    assert_equal(carrier_code_valid, result.shipment.carrier.code, "The package number that's returned matches the carrier code that was specified")
  end
end
