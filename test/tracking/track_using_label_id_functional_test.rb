# frozen_string_literal: true

require "test_helper"

#
# <Description>
#
# @param expected_arr [Hash]
def assert_tracking_response(expected, actual_response)
  assert_equal(expected[:tracking_number], actual_response.tracking_number) if expected.key?(:tracking_number)
  assert_equal(expected[:status_code], actual_response.status_code) if expected.key?(:status_code)
  assert_equal(expected[:status_description], actual_response.status_description) if expected.key?(:status_description)
  assert_equal(expected[:carrier_status_code], actual_response.carrier_status_code) if expected.key?(:carrier_status_code)
  assert_equal(expected[:carrier_status_description], actual_response.carrier_status_description) if expected.key?(:carrier_status_description)
  assert_equal(expected[:shipped_date], actual_response.shipped_date) if expected.key?(:shipped_date)
  assert_equal(expected[:estimated_delivery_date], actual_response.estimated_delivery_date) if expected.key?(:estimated_delivery_date)
  assert_equal(expected[:actual_delivery_date], actual_response.actual_delivery_date) if expected.key?(:actual_delivery_date)
  assert_equal(expected[:exception_description], actual_response.exception_description) if expected.key?(:exception_description)

  expected[:events].each_with_index do |event, idx|
    assert_event(event, actual_response.events[idx])
  end
end

def assert_event(expected, actual_event)
  assert_equal(expected[:occurred_at], actual_event.occurred_at) if expected.key?(:occurred_at)
  assert_equal(expected[:carrier_occurred_at], actual_event.carrier_occurred_at) if expected.key?(:carrier_occurred_at)
  assert_equal(expected[:description], actual_event.description) if expected.key?(:description)
  assert_equal(expected[:city_locality], actual_event.city_locality) if expected.key?(:city_locality)
  assert_equal(expected[:state_province], actual_event.state_province) if expected.key?(:state_province)
  assert_equal(expected[:postal_code], actual_event.postal_code) if expected.key?(:postal_code)
  assert_equal(expected[:country_code], actual_event.country_code) if expected.key?(:country_code)
  assert_equal(expected[:company_name], actual_event.company_name) if expected.key?(:company_name)
  assert_equal(expected[:signer], actual_event.signer) if expected.key?(:signer)
  assert_equal(expected[:event_code], actual_event.event_code) if expected.key?(:event_code)
end

describe "Track using label id: Functional" do
  after do
    WebMock.reset!
  end
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  it "handles unauthorized errors" do
    stub = stub_request(:get, "https://api.shipengine.com/v1/labels/se-324658/track")
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
      client.track_using_label_id("se-324658")
      assert_requested(stub, times: 1)
    end
  end

  it "handles a successful response for track_using_label_id" do
    stub = stub_request(:get, "https://api.shipengine.com/v1/labels/se-324658/track")
      .to_return(status: 200, body: {
        "tracking_number": "1Z932R800390810600",
        "status_code": "DE",
        "status_description": "Delivered",
        "carrier_status_code": "D",
        "carrier_status_description": "DELIVERED",
        "shipped_date": "2019-07-27T11:59:03.289Z",
        "estimated_delivery_date": "2019-07-27T11:59:03.289Z",
        "actual_delivery_date": "2019-07-27T11:59:03.289Z",
        "exception_description": nil,
        "events": [
          {
            "occurred_at": "2019-09-13T12:32:00Z",
            "carrier_occurred_at": "2019-09-13T05:32:00",
            "description": "Arrived at USPS Facility",
            "city_locality": "OCEANSIDE",
            "state_province": "CA",
            "postal_code": "92056",
            "country_code": "",
            "company_name": "",
            "signer": "",
            "event_code": "U1",
          },
        ],
      }.to_json)

    expected = {
      tracking_number: "1Z932R800390810600",
      status_code: "DE",
      status_description: "Delivered",
      carrier_status_code: "D",
      carrier_status_description: "DELIVERED",
      shipped_date: "2019-07-27T11:59:03.289Z",
      estimated_delivery_date: "2019-07-27T11:59:03.289Z",
      actual_delivery_date: "2019-07-27T11:59:03.289Z",
      exception_description: nil,
      events: [
        {
          occurred_at: "2019-09-13T12:32:00Z",
          carrier_occurred_at: "2019-09-13T05:32:00",
          description: "Arrived at USPS Facility",
          city_locality: "OCEANSIDE",
          state_province: "CA",
          postal_code: "92056",
          country_code: "",
          company_name: "",
          signer: "",
          event_code: "U1",
        },
      ],
    }

    actual_response = client.track_using_label_id("se-324658")
    assert_tracking_response(expected, actual_response)
    assert_requested(stub, times: 1)
  end
end
