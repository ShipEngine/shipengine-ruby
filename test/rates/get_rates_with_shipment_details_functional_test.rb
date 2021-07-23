# frozen_string_literal: true

require "test_helper"

#
# <Description>
#
# @param expected_arr [Hash]
def assert_rates_response(expected, actual_response)
  assert_equal(expected[:shipment_id], actual_response.shipment_id) if expected.key?(:shipment_id)
  assert_equal(expected[:carrier_id], actual_response.carrier_id) if expected.key?(:carrier_id)
  assert_equal(expected[:service_code], actual_response.service_code) if expected.key?(:service_code)
  assert_equal(expected[:external_order_id], actual_response.external_order_id) if expected.key?(:external_order_id)
  assert_equal(expected[:carrier_status_description], actual_response.carrier_status_description) if expected.key?(:carrier_status_description)
  assert_equal(expected[:external_shipment_id], actual_response.external_shipment_id) if expected.key?(:external_shipment_id)
  assert_equal(expected[:ship_date], actual_response.ship_date) if expected.key?(:ship_date)
  assert_equal(expected[:created_at], actual_response.created_at) if expected.key?(:created_at)
  assert_equal(expected[:modified_at], actual_response.modified_at) if expected.key?(:modified_at)
  assert_equal(expected[:shipment_status], actual_response.shipment_status) if expected.key?(:shipment_status)
  assert_equal(expected[:warehouse_id], actual_response.warehouse_id) if expected.key?(:warehouse_id)
  assert_equal(expected[:confirmation], actual_response.confirmation) if expected.key?(:confirmation)
  assert_equal(expected[:origin_type], actual_response.origin_type) if expected.key?(:origin_type)
  assert_equal(expected[:insurance_provider], actual_response.insurance_provider) if expected.key?(:insurance_provider)
  assert_equal(expected[:order_source_code], actual_response.order_source_code) if expected.key?(:order_source_code)

  assert_address(expected[:ship_to], actual_response.ship_to) if expected.key?(:ship_to)
  assert_address(expected[:ship_from], actual_response.ship_from) if expected.key?(:ship_from)
  assert_address(expected[:return_to], actual_response.return_to) if expected.key?(:return_to)

  assert_advanced_options(expected[:advanced_options], actual_response.advanced_options) if expected.key?(:advanced_options)
  assert_customs(expected[:customs], actual_response.customs) if expected.key?(:customs)

  expected[:tags].each_with_index do |tag, idx|
    assert_tag(tag, actual_response.tags[idx])
  end

  expected[:packages].each_with_index do |package, idx|
    assert_package(package, actual_response.packages[idx])
  end

  expected[:tax_identifiers].each_with_index do |tax_identifier, idx|
    assert_tax_identifier(tax_identifier, actual_response.tax_identifiers[idx])
  end

  expected[:items].each_with_index do |item, idx|
    assert_item(item, actual_response.items[idx])
  end

  assert_rate_response(expected[:rate_response], actual_response.rate_response) if expected.key?(:rate_response)
end

def assert_address(expected_address, response_address)
  assert_equal(expected_address[:address_line1], response_address.address_line1, "-> address_line1") if expected_address.key?(:address_line1)
  assert_equal(expected_address[:address_line2], response_address.address_line2, "-> address_line2") if expected_address.key?(:address_line2) && expected_address[:address_line2]
  assert_equal(expected_address[:address_line3], response_address.address_line3, "-> address_line3") if expected_address.key?(:address_line3) && expected_address[:address_line3]
  assert_equal(expected_address[:name], response_address.name, "-> name") if expected_address.key?(:name) && expected_address[:name]
  assert_equal(expected_address[:company_name], response_address.company_name, "-> company_name") if expected_address.key?(:company_name) && expected_address[:company_name]
  assert_equal(expected_address[:phone], response_address.phone, "-> phone") if expected_address.key?(:phone) && expected_address[:phone]
  assert_equal(expected_address[:city_locality], response_address.city_locality, "-> city_locality") if expected_address.key?(:city_locality) && expected_address[:city_locality]
  assert_equal(expected_address[:state_province], response_address.state_province, "-> state_province") if expected_address.key?(:state_province) && expected_address[:state_province]
  assert_equal(expected_address[:postal_code], response_address.postal_code, "-> postal_code") if expected_address.key?(:postal_code) && expected_address[:postal_code]
  assert_equal(expected_address[:country_code], response_address.country_code, "-> country_code") if expected_address.key?(:country_code) && expected_address[:country_code]
  assert_equal(expected_address[:address_residential_indicator], response_address.address_residential_indicator, "-> address_residential_indicator") if expected_address.key?(:address_residential_indicator) && expected_address[:address_residential_indicator]
end

def assert_advanced_options(expected, actual_advanced_options)
  assert_equal(expected[:bill_to_account], actual_advanced_options.bill_to_account) if expected.key?(:bill_to_account)
  assert_equal(expected[:bill_to_country_code], actual_advanced_options.bill_to_country_code) if expected.key?(:bill_to_country_code)
  assert_equal(expected[:bill_to_party], actual_advanced_options.bill_to_party) if expected.key?(:bill_to_party)
  assert_equal(expected[:bill_to_postal_code], actual_advanced_options.bill_to_postal_code) if expected.key?(:bill_to_postal_code)
  assert_equal(expected[:contains_alcohol], actual_advanced_options.contains_alcohol) if expected.key?(:contains_alcohol)
  assert_equal(expected[:delivered_duty_paid], actual_advanced_options.delivered_duty_paid) if expected.key?(:delivered_duty_paid)
  assert_equal(expected[:dry_ice], actual_advanced_options.dry_ice) if expected.key?(:dry_ice)
  assert_weight(expected[:dry_ice_weight], actual_advanced_options.dry_ice_weight) if expected.key?(:dry_ice_weight)
  assert_equal(expected[:non_machinable], actual_advanced_options.non_machinable) if expected.key?(:non_machinable)
  assert_equal(expected[:saturday_delivery], actual_advanced_options.saturday_delivery) if expected.key?(:saturday_delivery)
  assert_equal(expected[:use_ups_ground_freight_pricing], actual_advanced_options.use_ups_ground_freight_pricing) if expected.key?(:use_ups_ground_freight_pricing)
  assert_equal(expected[:freight_class], actual_advanced_options.freight_class) if expected.key?(:freight_class)
  assert_equal(expected[:custom_field1], actual_advanced_options.custom_field1) if expected.key?(:custom_field1)
  assert_equal(expected[:custom_field2], actual_advanced_options.custom_field2) if expected.key?(:custom_field2)
  assert_equal(expected[:custom_field3], actual_advanced_options.custom_field3) if expected.key?(:custom_field3)
  assert_equal(expected[:origin_type], actual_advanced_options.origin_type) if expected.key?(:origin_type)
  assert_equal(expected[:shipper_release], actual_advanced_options.shipper_release) if expected.key?(:shipper_release)
  assert_collect_on_delivery(expected[:collect_on_delivery], actual_advanced_options.collect_on_delivery) if expected.key?(:collect_on_delivery)
end

def assert_collect_on_delivery(expected, actual_collect_on_delivery)
  assert_equal(expected[:payment_type], actual_collect_on_delivery.payment_type) if expected.key?(:payment_type)
  assert_monetary_value(expected[:payment_amount], actual_collect_on_delivery.payment_amount) if expected.key?(:payment_amount)
end

def assert_customs(expected, actual_customs)
  assert_equal(expected[:contents], actual_customs.contents) if expected.key?(:contents)
  assert_equal(expected[:non_delivery], actual_customs.non_delivery) if expected.key?(:non_delivery)

  expected[:customs_items].each_with_index do |customs_item, idx|
    assert_customs_item(customs_item, actual_response.customs_items[idx])
  end
end

def assert_customs_item(expected, actual_customs_item)
  assert_equal(expected[:customs_item_id], actual_customs_item.customs_item_id) if expected.key?(:customs_item_id)
  assert_equal(expected[:description], actual_customs_item.description) if expected.key?(:description)
  assert_equal(expected[:quantity], actual_customs_item.quantity) if expected.key?(:quantity)
  assert_monetary_value(expected[:value], actual_customs_item.value) if expected.key?(:value)
  assert_equal(expected[:harmonized_tariff_code], actual_customs_item.harmonized_tariff_code) if expected.key?(:harmonized_tariff_code)
  assert_equal(expected[:country_of_origin], actual_customs_item.country_of_origin) if expected.key?(:country_of_origin)
  assert_equal(expected[:unit_of_measure], actual_customs_item.unit_of_measure) if expected.key?(:unit_of_measure)
  assert_equal(expected[:sku], actual_customs_item.sku) if expected.key?(:sku)
  assert_equal(expected[:sku_description], actual_customs_item.sku_description) if expected.key?(:sku_description)
end

def assert_tag(expected, actual_tag)
  assert_equal(expected[:name], actual_tag.name) if expected.key?(:name)
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

def assert_rate_response(expected, actual_rate_response)
  expected[:rates].each_with_index do |rate, idx|
    assert_rate(rate, actual_rate_response.rates[idx])
  end
  expected[:invalid_rates].each_with_index do |invalid_rate, idx|
    assert_rate(invalid_rate, actual_rate_response.invalid_rates[idx])
  end
  assert_equal(expected[:rate_request_id], actual_rate_response.rate_request_id) if expected.key?(:rate_request_id)
  assert_equal(expected[:shipment_id], actual_rate_response.shipment_id) if expected.key?(:shipment_id)
  assert_equal(expected[:created_at], actual_rate_response.created_at) if expected.key?(:created_at)
  assert_equal(expected[:status], actual_rate_response.status) if expected.key?(:status)

  expected[:errors].each_with_index do |error, idx|
    assert_error(error, actual_rate_response.errors[idx])
  end
end

def assert_rate(expected, actual_rate)
  assert_equal(expected[:rate_id], actual_rate.rate_id) if expected.key?(:rate_id)
  assert_equal(expected[:rate_type], actual_rate.rate_type) if expected.key?(:rate_type)
  assert_equal(expected[:carrier_id], actual_rate.carrier_id) if expected.key?(:carrier_id)
  assert_monetary_value(expected[:shipping_amount], actual_rate.shipping_amount) if expected.key?(:shipping_amount)
  assert_monetary_value(expected[:insurance_amount], actual_rate.insurance_amount) if expected.key?(:insurance_amount)
  assert_monetary_value(expected[:confirmation_amount], actual_rate.confirmation_amount) if expected.key?(:confirmation_amount)
  assert_monetary_value(expected[:other_amount], actual_rate.other_amount) if expected.key?(:other_amount)
  assert_monetary_value(expected[:tax_amount], actual_rate.tax_amount) if expected.key?(:tax_amount)
  assert_equal(expected[:zone], actual_rate.zone) if expected.key?(:zone)
  assert_equal(expected[:package_type], actual_rate.package_type) if expected.key?(:package_type)
  assert_equal(expected[:delivery_days], actual_rate.delivery_days) if expected.key?(:delivery_days)
  assert_equal(expected[:guaranteed_service], actual_rate.guaranteed_service) if expected.key?(:guaranteed_service)
  assert_equal(expected[:estimated_delivery_date], actual_rate.estimated_delivery_date) if expected.key?(:estimated_delivery_date)
  assert_equal(expected[:carrier_delivery_days], actual_rate.carrier_delivery_days) if expected.key?(:carrier_delivery_days)
  assert_equal(expected[:ship_date], actual_rate.ship_date) if expected.key?(:ship_date)
  assert_equal(expected[:negotiated_rate], actual_rate.negotiated_rate) if expected.key?(:negotiated_rate)
  assert_equal(expected[:service_type], actual_rate.service_type) if expected.key?(:service_type)
  assert_equal(expected[:service_code], actual_rate.service_code) if expected.key?(:service_code)
  assert_equal(expected[:trackable], actual_rate.trackable) if expected.key?(:trackable)
  assert_equal(expected[:carrier_code], actual_rate.carrier_code) if expected.key?(:carrier_code)
  assert_equal(expected[:carrier_nickname], actual_rate.carrier_nickname) if expected.key?(:carrier_nickname)
  assert_equal(expected[:carrier_friendly_name], actual_rate.carrier_friendly_name) if expected.key?(:carrier_friendly_name)
  assert_equal(expected[:validation_status], actual_rate.validation_status) if expected.key?(:validation_status)
  assert_equal(expected[:warning_messages], actual_rate.warning_messages) if expected.key?(:warning_messages)
  assert_equal(expected[:error_messages], actual_rate.error_messages) if expected.key?(:error_messages)
end

def assert_item(expected, actual_item)
  assert_equal(expected[:name], actual_item.name) if expected.key?(:name)
  assert_equal(expected[:sales_order_id], actual_item.sales_order_id) if expected.key?(:sales_order_id)
  assert_equal(expected[:sales_order_item_id], actual_item.sales_order_item_id) if expected.key?(:sales_order_item_id)
  assert_equal(expected[:quantity], actual_item.quantity) if expected.key?(:quantity)
  assert_equal(expected[:sku], actual_item.sku) if expected.key?(:sku)
  assert_equal(expected[:external_order_id], actual_item.external_order_id) if expected.key?(:external_order_id)
  assert_equal(expected[:external_order_item_id], actual_item.external_order_item_id) if expected.key?(:external_order_item_id)
  assert_equal(expected[:asin], actual_item.asin) if expected.key?(:asin)
  assert_equal(expected[:order_source_code], actual_item.order_source_code) if expected.key?(:order_source_code)
end

def assert_tax_identifier(expected, actual_tax_idetifier)
  assert_equal(expected[:taxable_entity_type], actual_tax_idetifier.taxable_entity_type) if expected.key?(:taxable_entity_type)
  assert_equal(expected[:identifier_type], actual_tax_idetifier.identifier_type) if expected.key?(:identifier_type)
  assert_equal(expected[:issuing_authority], actual_tax_idetifier.issuing_authority) if expected.key?(:issuing_authority)
  assert_equal(expected[:value], actual_tax_idetifier.value) if expected.key?(:value)
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

def assert_label_messages(expected, actual_label_messages)
  assert_equal(expected[:reference1], actual_label_messages.reference1) if expected.key?(:reference1)
  assert_equal(expected[:reference2], actual_label_messages.reference1) if expected.key?(:reference2)
  assert_equal(expected[:reference3], actual_label_messages.reference1) if expected.key?(:reference3)
end

def assert_error(expected, actual_error)
  assert_equal(expected[:error_source], actual_error.error_source) if expected.key?(:error_source)
  assert_equal(expected[:error_type], actual_error.error_type) if expected.key?(:error_type)
  assert_equal(expected[:error_code], actual_error.error_code) if expected.key?(:error_code)
  assert_equal(expected[:message], actual_error.message) if expected.key?(:message)
end

describe "Get rate with shipment details: Functional test" do
  after do
    WebMock.reset!
  end

  client = ::ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")

  it "handles unauthorized errors" do
    stub = stub_request(:post, "https://api.shipengine.com/v1/rates")
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
      client.get_rates_with_shipment_details({
        rate_options: {
          carrier_ids: [
            "se-123890",
          ],
        },
        shipment: {
          validate_address: "no_validation",
          ship_to: {
            name: "Amanda Miller",
            phone: "555-555-5555",
            address_line1: "525 S Winchester Blvd",
            city_locality: "San Jose",
            state_province: "CA",
            postal_code: "95128",
            country_code: "US",
            address_residential_indicator: "yes",
          },
          ship_from: {
            company_name: "Example Corp.",
            name: "John Doe",
            phone: "111-111-1111",
            address_line1: "4009 Marathon Blvd",
            address_line2: "Suite 300",
            city_locality: "Austin",
            state_province: "TX",
            postal_code: "78756",
            country_code: "US",
            address_residential_indicator: "no",
          },
          packages: [
            {
              weight: {
                value: 1.0,
                unit: "ounce",
              },
            },
          ],
        },
      })
      assert_requested(stub, times: 1)
    end
  end

  it "handles a successful response for get_rates_with_shipment_details" do
    stub = stub_request(:post, "https://api.shipengine.com/v1/rates")
      .to_return(status: 200, body: {
        "shipment_id": "se-28529731",
        "carrier_id": "se-28529731",
        "service_code": "usps_first_class_mail",
        "external_order_id": "string",
        "items": [],
        "tax_identifiers": [
          {
            "taxable_entity_type": "shipper",
            "identifier_type": "vat",
            "issuing_authority": "string",
            "value": "string",
          },
        ],
        "external_shipment_id": "string",
        "ship_date": "2018-09-23T00:00:00.000Z",
        "created_at": "2018-09-23T15:00:00.000Z",
        "modified_at": "2018-09-23T15:00:00.000Z",
        "shipment_status": "pending",
        "ship_to": {
          "name": "John Doe",
          "phone": "+1 204-253-9411 ext. 123",
          "company_name": "The Home Depot",
          "address_line1": "1999 Bishop Grandin Blvd.",
          "address_line2": "Unit 408",
          "address_line3": "Building #7",
          "city_locality": "Winnipeg",
          "state_province": "Manitoba",
          "postal_code": "78756-3717",
          "country_code": "CA",
          "address_residential_indicator": "no",
        },
        "ship_from": {
          "name": "John Doe",
          "phone": "+1 204-253-9411 ext. 123",
          "company_name": "The Home Depot",
          "address_line1": "1999 Bishop Grandin Blvd.",
          "address_line2": "Unit 408",
          "address_line3": "Building #7",
          "city_locality": "Winnipeg",
          "state_province": "Manitoba",
          "postal_code": "78756-3717",
          "country_code": "CA",
          "address_residential_indicator": "no",
        },
        "warehouse_id": "se-28529731",
        "return_to": {
          "name": "John Doe",
          "phone": "+1 204-253-9411 ext. 123",
          "company_name": "The Home Depot",
          "address_line1": "1999 Bishop Grandin Blvd.",
          "address_line2": "Unit 408",
          "address_line3": "Building #7",
          "city_locality": "Winnipeg",
          "state_province": "Manitoba",
          "postal_code": "78756-3717",
          "country_code": "CA",
          "address_residential_indicator": "no",
        },
        "confirmation": "none",
        "customs": {
          "contents": "merchandise",
          "non_delivery": "return_to_sender",
          "customs_items": [],
        },
        "advanced_options": {
          "bill_to_account": nil,
          "bill_to_country_code": "CA",
          "bill_to_party": "recipient",
          "bill_to_postal_code": nil,
          "contains_alcohol": false,
          "delivered_duty_paid": false,
          "dry_ice": false,
          "dry_ice_weight": {
            "value": 0,
            "unit": "pound",
          },
          "non_machinable": false,
          "saturday_delivery": false,
          "use_ups_ground_freight_pricing": nil,
          "freight_class": 77.5,
          "custom_field1": nil,
          "custom_field2": nil,
          "custom_field3": nil,
          "origin_type": "pickup",
          "shipper_release": nil,
          "collect_on_delivery": {
            "payment_type": "any",
            "payment_amount": {
              "currency": "usd",
              "amount": 0,
            },
          },
        },
        "origin_type": "pickup",
        "insurance_provider": "none",
        "tags": [],
        "order_source_code": "amazon_ca",
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
              "0": {
                "currency": "usd",
                "amount": 0,
              },
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
        "total_weight": {
          "value": 0,
          "unit": "pound",
        },
        "rate_response": {
          "rates": [
            {
              "rate_id": "se-28529731",
              "rate_type": "check",
              "carrier_id": "se-28529731",
              "shipping_amount": {
                "currency": "usd",
                "amount": 0,
              },
              "insurance_amount": {
                "currency": "usd",
                "amount": 0,
              },
              "confirmation_amount": {
                "currency": "usd",
                "amount": 0,
              },
              "other_amount": {
                "currency": "usd",
                "amount": 0,
              },
              "tax_amount": {
                "currency": "usd",
                "amount": 0,
              },
              "zone": 6,
              "package_type": "package",
              "delivery_days": 5,
              "guaranteed_service": true,
              "estimated_delivery_date": "2018-09-23T00:00:00.000Z",
              "carrier_delivery_days": "string",
              "ship_date": "2021-07-23T14:49:13Z",
              "negotiated_rate": true,
              "service_type": "string",
              "service_code": "string",
              "trackable": true,
              "carrier_code": "string",
              "carrier_nickname": "string",
              "carrier_friendly_name": "string",
              "validation_status": "valid",
              "warning_messages": [
                "string",
              ],
              "error_messages": [
                "string",
              ],
            },
          ],
          "invalid_rates": [],
          "rate_request_id": "se-28529731",
          "shipment_id": "se-28529731",
          "created_at": "se-28529731",
          "status": "working",
          "errors": [
            {
              "error_source": "carrier",
              "error_type": "account_status",
              "error_code": "auto_fund_not_supported",
              "message": "Body of request cannot be nil.",
            },
          ],
        },
      }.to_json)

    expected = {
      shipment_id: "se-28529731",
      carrier_id: "se-28529731",
      service_code: "usps_first_class_mail",
      external_order_id: "string",
      items: [],
      tax_identifiers: [
        {
          taxable_entity_type: "shipper",
          identifier_type: "vat",
          issuing_authority: "string",
          value: "string",
        },
      ],
      external_shipment_id: "string",
      ship_date: "2018-09-23T00:00:00.000Z",
      created_at: "2018-09-23T15:00:00.000Z",
      modified_at: "2018-09-23T15:00:00.000Z",
      shipment_status: "pending",
      ship_to: {
        name: "John Doe",
        phone: "+1 204-253-9411 ext. 123",
        company_name: "The Home Depot",
        address_line1: "1999 Bishop Grandin Blvd.",
        address_line2: "Unit 408",
        address_line3: "Building #7",
        city_locality: "Winnipeg",
        state_province: "Manitoba",
        postal_code: "78756-3717",
        country_code: "CA",
        address_residential_indicator: "no",
      },
      ship_from: {
        name: "John Doe",
        phone: "+1 204-253-9411 ext. 123",
        company_name: "The Home Depot",
        address_line1: "1999 Bishop Grandin Blvd.",
        address_line2: "Unit 408",
        address_line3: "Building #7",
        city_locality: "Winnipeg",
        state_province: "Manitoba",
        postal_code: "78756-3717",
        country_code: "CA",
        address_residential_indicator: "no",
      },
      warehouse_id: "se-28529731",
      return_to: {
        name: "John Doe",
        phone: "+1 204-253-9411 ext. 123",
        company_name: "The Home Depot",
        address_line1: "1999 Bishop Grandin Blvd.",
        address_line2: "Unit 408",
        address_line3: "Building #7",
        city_locality: "Winnipeg",
        state_province: "Manitoba",
        postal_code: "78756-3717",
        country_code: "CA",
        address_residential_indicator: "no",
      },
      confirmation: "none",
      customs: {
        contents: "merchandise",
        non_delivery: "return_to_sender",
        customs_items: [],
      },
      advanced_options: {
        bill_to_account: nil,
        bill_to_country_code: "CA",
        bill_to_party: "recipient",
        bill_to_postal_code: nil,
        contains_alcohol: false,
        delivered_duty_paid: false,
        dry_ice: false,
        dry_ice_weight: {
          value: 0,
          unit: "pound",
        },
        non_machinable: false,
        saturday_delivery: false,
        use_ups_ground_freight_pricing: nil,
        freight_class: 77.5,
        custom_field1: nil,
        custom_field2: nil,
        custom_field3: nil,
        origin_type: "pickup",
        shipper_release: nil,
        collect_on_delivery: {
          payment_type: "any",
          payment_amount: {
            currency: "usd",
            amount: 0,
          },
        },
      },
      origin_type: "pickup",
      insurance_provider: "none",
      tags: [],
      order_source_code: "amazon_ca",
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
      total_weight: {
        value: 0,
        unit: "pound",
      },
      rate_response: {
        rates: [
          {
            rate_id: "se-28529731",
            rate_type: "check",
            carrier_id: "se-28529731",
            shipping_amount: {
              currency: "usd",
              amount: 0,
            },
            insurance_amount: {
              currency: "usd",
              amount: 0,
            },
            confirmation_amount: {
              currency: "usd",
              amount: 0,
            },
            other_amount: {
              currency: "usd",
              amount: 0,
            },
            tax_amount: {
              currency: "usd",
              amount: 0,
            },
            zone: 6,
            package_type: "package",
            delivery_days: 5,
            guaranteed_service: true,
            estimated_delivery_date: "2018-09-23T00:00:00.000Z",
            carrier_delivery_days: "string",
            ship_date: "2021-07-23T14:49:13Z",
            negotiated_rate: true,
            service_type: "string",
            service_code: "string",
            trackable: true,
            carrier_code: "string",
            carrier_nickname: "string",
            carrier_friendly_name: "string",
            validation_status: "valid",
            warning_messages: [
              "string",
            ],
            error_messages: [
              "string",
            ],
          },
        ],
        invalid_rates: [],
        rate_request_id: "se-28529731",
        shipment_id: "se-28529731",
        created_at: "se-28529731",
        status: "working",
        errors: [
          {
            error_source: "carrier",
            error_type: "account_status",
            error_code: "auto_fund_not_supported",
            message: "Body of request cannot be nil.",
          },
        ],
      },
    }

    actual_response = client.get_rates_with_shipment_details({
      rate_options: {
        carrier_ids: [
          "se-123890",
        ],
      },
      shipment: {
        validate_address: "no_validation",
        ship_to: {
          name: "Amanda Miller",
          phone: "555-555-5555",
          address_line1: "525 S Winchester Blvd",
          city_locality: "San Jose",
          state_province: "CA",
          postal_code: "95128",
          country_code: "US",
          address_residential_indicator: "yes",
        },
        ship_from: {
          company_name: "Example Corp.",
          name: "John Doe",
          phone: "111-111-1111",
          address_line1: "4009 Marathon Blvd",
          address_line2: "Suite 300",
          city_locality: "Austin",
          state_province: "TX",
          postal_code: "78756",
          country_code: "US",
          address_residential_indicator: "no",
        },
        packages: [
          {
            weight: {
              value: 1.0,
              unit: "ounce",
            },
          },
        ],
      },
    })

    assert_rates_response(expected, actual_response)
    assert_requested(stub, times: 1)
  end
end
