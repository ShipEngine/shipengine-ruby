# frozen_string_literal: true

require "test_helper"

#
# <Description>
#
# @param expected_arr [Hash]
def assert_void_label_response(expected, actual_response)
  assert_equal(expected[:approved], actual_response.approved) if expected.key?(:approved)
  assert_equal(expected[:message], actual_response.message) if expected.key?(:message)
end

describe "Void Label from Label Id: Functional" do
  after do
    WebMock.reset!
  end
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  it "handles unauthorized errors" do
    stub = stub_request(:put, "https://api.shipengine.com/v1/labels/se-28529731/void")
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
      client.void_label_with_label_id("se-28529731")
      assert_requested(stub, times: 1)
    end
  end

  it "handles a successful response for void label" do
    stub = stub_request(:put, "https://api.shipengine.com/v1/labels/se-28529731/void")
      .to_return(status: 200, body: {
        "approved": true,
        "message": "Request for refund submitted.  This label has been voided.",
      }.to_json)

    expected = {
      approved: true,
      message: "Request for refund submitted.  This label has been voided.",
    }

    actual_response = client.void_label_with_label_id("se-28529731")
    assert_void_label_response(expected, actual_response)
    assert_requested(stub, times: 1)
  end
end
