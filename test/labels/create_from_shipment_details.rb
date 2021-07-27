# frozen_string_literal: true

require "test_helper"

#
# <Description>
#
# @param expected_arr [Hash]
def assert_label_response(expected, actual_response)
  assert_equal(expected[:label_id], actual_response.label_id) if expected.key?(:label_id)
  assert_equal(expected[:status], actual_response.status) if expected.key?(:status)
  assert_equal(expected[:shipment_id], actual_response.shipment_id) if expected.key?(:shipment_id)
  assert_equal(expected[:ship_date], actual_response.ship_date) if expected.key?(:ship_date)
  assert_equal(expected[:created_at], actual_response.created_at) if expected.key?(:created_at)
  assert_equal(expected[:tracking_number], actual_response.tracking_number) if expected.key?(:tracking_number)
  assert_equal(expected[:is_return_label], actual_response.is_return_label) if expected.key?(:is_return_label)
  assert_equal(expected[:rma_number], actual_response.rma_number) if expected.key?(:rma_number)
  assert_equal(expected[:is_international], actual_response.is_international) if expected.key?(:is_international)
  assert_equal(expected[:batch_id], actual_response.batch_id) if expected.key?(:batch_id)
  assert_equal(expected[:carrier_id], actual_response.carrier_id) if expected.key?(:carrier_id)
  assert_equal(expected[:charge_event], actual_response.charge_event) if expected.key?(:charge_event)
  assert_equal(expected[:service_code], actual_response.service_code) if expected.key?(:service_code)
  assert_equal(expected[:package_code], actual_response.package_code) if expected.key?(:package_code)
  assert_equal(expected[:voided], actual_response.voided) if expected.key?(:voided)
  assert_equal(expected[:voided_at], actual_response.voided_at) if expected.key?(:voided_at)
  assert_equal(expected[:label_format], actual_response.label_format) if expected.key?(:label_format)
  assert_equal(expected[:display_scheme], actual_response.display_scheme) if expected.key?(:display_scheme)
  assert_equal(expected[:label_layout], actual_response.label_layout) if expected.key?(:label_layout)
  assert_equal(expected[:trackable], actual_response.trackable) if expected.key?(:trackable)
  assert_equal(expected[:label_image_id], actual_response.label_image_id) if expected.key?(:label_image_id)
  assert_equal(expected[:carrier_code], actual_response.carrier_code) if expected.key?(:carrier_code)
  assert_equal(expected[:tracking_status], actual_response.tracking_status) if expected.key?(:tracking_status)

  assert_monetary_value(expected[:shipment_cost], actual_response.shipment_cost) if expected.key?(:shipment_cost)
  assert_monetary_value(expected[:insurance_cost], actual_response.insurance_cost) if expected.key?(:insurance_cost)
  assert_label_download(expected[:label_download], actual_response.label_download) if expected.key?(:label_download)
  assert_form_download(expected[:form_download], actual_response.form_download) if expected.key?(:form_download)
  assert_insurance_claim(expected[:insurance_claim], actual_response.insurance_claim) if expected.key?(:insurance_claim)

  expected[:packages].each_with_index do |package, idx|
    assert_package(package, actual_response.packages[idx])
  end
end

def assert_form_download(expected, actual_form_download_response)
  assert_equal(expected[:href], actual_form_download_response.href) if expected.key?(:href)
  assert_equal(expected[:type], actual_form_download_response.type) if expected.key?(:type)
end

def assert_label_download(expected, actual_label_download_response)
  assert_equal(expected[:href], actual_label_download_response.href) if expected.key?(:href)
  assert_equal(expected[:pdf], actual_label_download_response.pdf) if expected.key?(:pdf)
  assert_equal(expected[:png], actual_label_download_response.png) if expected.key?(:png)
  assert_equal(expected[:zpl], actual_label_download_response.zpl) if expected.key?(:zpl)
end

def assert_insurance_claim(expected, actual_insurance_claim_response)
  assert_equal(expected[:href], actual_insurance_claim_response.href) if expected.key?(:href)
  assert_equal(expected[:type], actual_insurance_claim_response.type) if expected.key?(:type)
end

def assert_package(expected, actual_package)
  assert_equal(expected[:package_code], actual_package.package_code) if expected.key?(:package_code)
  assert_weight(expected[:weight], actual_package.weight) if expected.key?(:weight)
  assert_dimensions(expected[:dimensions], actual_package.dimensions) if expected.key?(:dimensions)
  assert_monetary_value(expected[:insured_value], actual_package.insured_value) if expected.key?(:insured_value)
  assert_equal(expected[:tracking_number], actual_package.tracking_number) if expected.key?(:tracking_number)
  assert_label_messages(expected[:label_messages], actual_package.label_messages) if expected.key?(:label_messages)
  assert_equal(expected[:external_package_id], actual_package.external_package_id) if expected.key?(:external_package_id)
end

def assert_monetary_value(expected, actual_value)
  assert_equal(expected[:value], actual_value.value) if expected.key?(:value)
  assert_equal(expected[:currency], actual_value.currency) if expected.key?(:currency)
end

def assert_dimensions(expected, actual_dimensions)
  assert_equal(expected[:length], actual_dimensions.length) if expected.key?(:length)
  assert_equal(expected[:width], actual_dimensions.width) if expected.key?(:width)
  assert_equal(expected[:height], actual_dimensions.height) if expected.key?(:height)
  assert_equal(expected[:unit], actual_dimensions.unit) if expected.key?(:unit)
end

def assert_weight(expected, actual_weight_response)
  assert_equal(expected[:value], actual_weight_response.value) if expected.key?(:value)
  assert_equal(expected[:unit], actual_weight_response.unit) if expected.key?(:unit)
end

describe "Create Label from Shipment Details: Functional" do
  after do
    WebMock.reset!
  end
  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  it "handles unauthorized errors" do
    stub = stub_request(:post, "https://api.shipengine.com/v1/labels")
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
      client.create_label_from_shipment_details({})
      assert_requested(stub, times: 1)
    end
  end

  it "handles a successful response for track_using_label_id" do
    stub = stub_request(:post, "https://api.shipengine.com/v1/labels")
      .to_return(status: 200, body: {
        "label_id": "se-28529731",
        "status": "processing",
        "shipment_id": "se-28529731",
        "ship_date": "2018-09-23T00:00:00.000Z",
        "created_at": "2018-09-23T15:00:00.000Z",
        "shipment_cost": {
          "currency": "usd",
          "amount": 0,
        },
        "insurance_cost": {
          "currency": "usd",
          "amount": 0,
        },
        "tracking_number": "782758401696",
        "is_return_label": true,
        "rma_number": "string",
        "is_international": true,
        "batch_id": "se-28529731",
        "carrier_id": "se-28529731",
        "charge_event": "carrier_default",
        "service_code": "usps_first_class_mail",
        "package_code": "small_flat_rate_box",
        "voided": true,
        "voided_at": "2018-09-23T15:00:00.000Z",
        "label_format": "pdf",
        "display_scheme": "label",
        "label_layout": "4x6",
        "trackable": true,
        "label_image_id": "img_DtBXupDBxREpHnwEXhTfgK",
        "carrier_code": "dhl_express",
        "tracking_status": "unknown",
        "label_download": {
          "href": "http://api.shipengine.com/v1/labels/se-28529731",
          "pdf": "http://api.shipengine.com/v1/labels/se-28529731",
          "png": "http://api.shipengine.com/v1/labels/se-28529731",
          "zpl": "http://api.shipengine.com/v1/labels/se-28529731",
        },
        "form_download": {
          "href": "http://api.shipengine.com/v1/labels/se-28529731",
          "type": "string",
        },
        "insurance_claim": {
          "href": "http://api.shipengine.com/v1/labels/se-28529731",
          "type": "string",
        },
        "packages": [
          {
            "package_code": "small_flat_rate_box",
            "weight": {
              "value": 0,
              "unit": "pound",
            },
            "dimensions": {
              "unit": "inch",
              "length": 0,
              "width": 0,
              "height": 0,
            },
            "insured_value": {
              "currency": "usd",
              "amount": 0,
            },
            "tracking_number": "1Z932R800392060079",
            "label_messages": {
              "reference1": nil,
              "reference2": nil,
              "reference3": nil,
            },
            "external_package_id": "string",
          },
        ],
      }.to_json)

    expected = {
      label_id: "se-28529731",
      status: "processing",
      shipment_id: "se-28529731",
      ship_date: "2018-09-23T00:00:00.000Z",
      created_at: "2018-09-23T15:00:00.000Z",
      shipment_cost: {
        currency: "usd",
        amount: 0,
      },
      insurance_cost: {
        currency: "usd",
        amount: 0,
      },
      tracking_number: "782758401696",
      is_return_label: true,
      rma_number: "string",
      is_international: true,
      batch_id: "se-28529731",
      carrier_id: "se-28529731",
      charge_event: "carrier_default",
      service_code: "usps_first_class_mail",
      package_code: "small_flat_rate_box",
      voided: true,
      voided_at: "2018-09-23T15:00:00.000Z",
      label_format: "pdf",
      display_scheme: "label",
      label_layout: "4x6",
      trackable: true,
      label_image_id: "img_DtBXupDBxREpHnwEXhTfgK",
      carrier_code: "dhl_express",
      tracking_status: "unknown",
      label_download: {
        href: "http://api.shipengine.com/v1/labels/se-28529731",
        pdf: "http://api.shipengine.com/v1/labels/se-28529731",
        png: "http://api.shipengine.com/v1/labels/se-28529731",
        zpl: "http://api.shipengine.com/v1/labels/se-28529731",
      },
      form_download: {
        href: "http://api.shipengine.com/v1/labels/se-28529731",
        type: "string",
      },
      insurance_claim: {
        href: "http://api.shipengine.com/v1/labels/se-28529731",
        type: "string",
      },
      packages: [
        {
          package_code: "small_flat_rate_box",
          weight: {
            value: 0,
            unit: "pound",
          },
          dimensions: {
            unit: "inch",
            length: 0,
            width: 0,
            height: 0,
          },
          insured_value: {
            currency: "usd",
            amount: 0,
          },
          tracking_number: "1Z932R800392060079",
          label_messages: {
            reference1: nil,
            reference2: nil,
            reference3: nil,
          },
          external_package_id: "string",
        },
      ],
    }

    actual_response = client.create_label_from_shipment_details({})
    assert_label_response(expected, actual_response)
    assert_requested(stub, times: 1)
  end
end
