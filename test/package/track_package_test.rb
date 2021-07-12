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

    # The shipmentId is populated, is not nil, and is a string.
    assert !result.shipment.shipment_id.nil?

    # The carrier_account_id is populated, is not nil, and is a string.
    assert !result.shipment.carrier_account_id.nil?, "The carrier_account_id is populated."
    assert result.shipment.carrier_account_id.is_a?(String)

    # The tracking_number is populated, is not nil, and is a string.
    assert !result.package.tracking_number.nil?
    assert result.package.tracking_number.is_a?(String)
  end

  it "DX-997 - Test initial scan tracking event" do
    package_id = "pkg_1FedExAccepted"
    result = client.track_package_by_id(package_id)

    assert !result.shipment.carrier.code.nil?
    assert !result.package.tracking_number.nil?
    assert result.events.count == 1
    assert result.shipment.to_hash["estimated_delivery_date"].class == Date
    assert !result.shipment.to_hash["estimated_delivery_date"].nil?
  end

  it "DX-998 - Test out for delivery tracking event" do
    package_id = "pkg_1FedExAttempted"
    result = client.track_package_by_id(package_id)

    assert !result.shipment.carrier.code.nil?
    assert !result.package.tracking_number.nil?
    assert result.events.count == 5
    assert result.events[0].status == "accepted"
    assert result.events[1].status == "in_transit"
    assert result.shipment.to_hash["estimated_delivery_date"].class == Date
    assert !result.shipment.to_hash["estimated_delivery_date"].nil?
    assert_tracking_events_in_order result.events
  end

  it "DX-999 - Test multiple delivery attempts" do
    package_id = "pkg_1FedexDeLiveredAttempted"
    result = client.track_package_by_id(package_id)

    assert !result.shipment.carrier.code.nil?
    assert !result.package.tracking_number.nil?
    assert result.events.count == 9
    assert result.shipment.to_hash["estimated_delivery_date"].class == Date
    assert !result.shipment.to_hash["estimated_delivery_date"].nil?
    assert_tracking_events_in_order result.events
    assert result.events[4].status == "attempted_delivery"
    assert result.events[6].status == "attempted_delivery"
  end

  it "DX-1000 - Test delivered on first try." do
    package_id = "pkg_1FedExDeLivered"
    result = client.track_package_by_id(package_id)

    assert !result.nil?
    assert !result.shipment.carrier.code.nil?
    assert !result.package.tracking_number.nil?
    assert result.shipment.to_hash["estimated_delivery_date"].class == Date
    assert !result.shipment.to_hash["estimated_delivery_date"].nil?
    assert_tracking_events_in_order result.events
    assert result.events[0].status == "accepted"
    assert result.events[1].status == "in_transit"
    assert result.events[-1].status == "delivered"
  end

  it "DX-1001 - Test delivered with signature." do
    package_id = "pkg_1FedExDeLivered"
    result = client.track_package_by_id(package_id)

    assert !result.shipment.carrier.code.nil?
    assert !result.package.tracking_number.nil?
    assert result.events.count > 3
    assert result.events.count == 5
    assert result.shipment.to_hash["estimated_delivery_date"].class == Date
    assert !result.shipment.to_hash["estimated_delivery_date"].nil?
    assert_tracking_events_in_order result.events
    assert result.events[0].status == "accepted"
    assert result.events[1].status == "in_transit"
    assert result.events[4].status == "delivered"
    assert !result.events[4].signer.nil?
  end

  it "DX-1011 Tests packageId not found" do
    package_id = "pkg_123"
    expected_err = {
      source: "shipengine",
      code: "invalid_identifier",
      type: "validation",
      message: "Package ID #{package_id} does not exist.",
      request_id: :__REGEX_MATCH__,
    }

    assert_raises_shipengine(::ShipEngine::Exceptions::ValidationError, expected_err) do
      client.track_package_by_id(package_id)
    end
  end
end
