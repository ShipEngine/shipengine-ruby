# frozen_string_literal: true

require "test_helper"
require "shipengine"

describe "track package" do
  client = ::ShipEngine::Client.new("abc1234")

  it "DX-993 Tracks a package using a tracking number and carrier code" do
    tracking_number_valid = "aaaaa_delivered"
    carrier_code_valid = "fedex"

    # The tracking number that's returned matches the tracking number that was specified
    result = client.track_package_by_tracking_number(tracking_number_valid, carrier_code_valid)
    p result
    assert_equal(
      tracking_number_valid,
      result.package.tracking_number,
      "The carrier that's returned matches the carrier code that was specified"
    )

    # The carrier that's returned matches the carrier code that was specified
    assert(result.shipment, "shipment should exist")
    assert_equal(
      carrier_code_valid,
      result.shipment.carrier.code,
      "The package number that's returned matches the carrier code that was specified"
    )
  end

  it "DX-995 Tracks a package using a package_Id (label created in ShipEngine)" do
    package_id = "pkg_1FedExAccepted"
    result = client.track_package_by_id(package_id)

    # The packageId that's returned matches the packageId that was specified.
    assert_equal(
      package_id,
      result.package.package_id,
      "The packageId that is returned matches the packageId that was specified."
    )

    # The shipmentId is populated,, is not nil, and is a string.
    assert !result.shipment.shipment_id.nil?

    # The carrier_id is populated, is not nil, and is a string.
    assert !result.shipment.carrier_id.nil?, "The carrier_id is populated."
    assert result.shipment.carrier_id.is_a?(String)

    # The tracking_number is populated, is not nil, and is a string.
    assert !result.package.tracking_number.nil?
    assert result.package.tracking_number.is_a?(String)
  end
end
