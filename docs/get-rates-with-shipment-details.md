Get Rates With Shipment Details
======================================
Given some shipment details and rate options, this method returns a list of rate quotes. Please see [our docs](https://www.shipengine.com/docs/rates/) to learn more about calculating rates.

Input Parameters
-------------------------------------

The `get_rates_with_shipment_details` method accepts shipment related params detailed in the documentation above.

Output
--------------------------------
The `get_rates_with_shipment_details` method returns the rates that were calculated for the given shipment params in a response class of ShipEngine::Domain::Rates::GetWithShipmentDetails::Response.

Example
```ruby
def get_rates_with_shipment_details_demo_function()
	client = ShipEngine::Client.new("API-Key")

	rate_shipment_details = {
	  rate_options: {
	    carrier_ids: [
	      "se-423887"
	    ]
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
	      address_residential_indicator: "yes"
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
	      address_residential_indicator: "no"
	    },
	    packages: [
	      {
	        weight: {
	          value: 1.0,
	          unit: "ounce"
	        }
	      }
	    ]
	  }
	}


	begin
	  result = client.get_rates_with_shipment_details(rate_shipment_details)
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

get_rates_with_shipment_details_demo_function
```

Example Output
-----------------------------------------------------

### Successful Get Rates Result
```ruby
#<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response
 @advanced_options=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::AdvancedOptions
   @bill_to_account=nil,
   @bill_to_country_code=nil,
   @bill_to_party=nil,
   @bill_to_postal_code=nil,
   @collect_on_delivery=nil,
   @contains_alcohol=false,
   @custom_field1=nil,
   @custom_field2=nil,
   @custom_field3=nil,
   @delivered_duty_paid=false,
   @dry_ice=false,
   @dry_ice_weight=nil,
   @freight_class=nil,
   @non_machinable=false,
   @origin_type=nil,
   @saturday_delivery=false,
   @shipper_release=nil,
   @use_ups_ground_freight_pricing=nil>,
 @carrier_id="se-423887",
 @confirmation="none",
 @created_at="2021-08-03T19:39:09.587Z",
 @customs=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Customs
   @contents="merchandise",
   @customs_items=[],
   @non_delivery="return_to_sender">,
 @external_order_id=nil,
 @external_shipment_id=nil,
 @insurance_provider="none",
 @items=[],
 @modified_at="2021-08-03T19:39:09.587Z",
 @order_source_code=nil,
 @origin_type=nil,
 @packages=
  [#<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Package
    @dimensions=
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Dimensions
      @height=0.0,
      @length=0.0,
      @unit="inch",
      @width=0.0>,
    @external_package_id=nil,
    @insured_value=
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
      @amount=0.0,
      @currency="usd">,
    @label_messages=
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Package::LabelMessages
      @reference1=nil,
      @reference2=nil,
      @reference3=nil>,
    @package_code="package",
    @tracking_number=nil,
    @weight=
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Weight
      @unit="ounce",
      @value=1.0>>],
 @rate_response=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse
   @created_at="2021-08-03T19:39:10.4005405Z",
   @errors=[],
   @invalid_rates=[],
   @rate_request_id="se-86709952",
   @rates=
    [#<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="3",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=3,
      @error_messages=[],
      @estimated_delivery_date="2021-08-06T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="letter",
      @rate_id="se-795654951",
      @rate_type="shipment",
      @service_code="usps_first_class_mail",
      @service_type="USPS First Class Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.51,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=false,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="3",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=3,
      @error_messages=[],
      @estimated_delivery_date="2021-08-06T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="large_envelope_or_flat",
      @rate_id="se-795654952",
      @rate_type="shipment",
      @service_code="usps_first_class_mail",
      @service_type="USPS First Class Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=1.0,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=false,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="3",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=3,
      @error_messages=[],
      @estimated_delivery_date="2021-08-06T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="package",
      @rate_id="se-795654953",
      @rate_type="shipment",
      @service_code="usps_first_class_mail",
      @service_type="USPS First Class Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=3.35,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="package",
      @rate_id="se-795654954",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=8.52,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="medium_flat_rate_box",
      @rate_id="se-795654955",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=13.75,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="small_flat_rate_box",
      @rate_id="se-795654956",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=7.9,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="large_flat_rate_box",
      @rate_id="se-795654957",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=19.3,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_envelope",
      @rate_id="se-795654958",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=7.4,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_padded_envelope",
      @rate_id="se-795654959",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=8.0,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="regional_rate_box_a",
      @rate_id="se-795654960",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=11.63,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="regional_rate_box_b",
      @rate_id="se-795654961",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=20.1,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_legal_envelope",
      @rate_id="se-795654962",
      @rate_type="shipment",
      @service_code="usps_priority_mail",
      @service_type="USPS Priority Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=7.7,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="1-2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="package",
      @rate_id="se-795654963",
      @rate_type="shipment",
      @service_code="usps_priority_mail_express",
      @service_type="USPS Priority Mail Express",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=31.4,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="1-2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_envelope",
      @rate_id="se-795654964",
      @rate_type="shipment",
      @service_code="usps_priority_mail_express",
      @service_type="USPS Priority Mail Express",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=22.75,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="1-2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_padded_envelope",
      @rate_id="se-795654965",
      @rate_type="shipment",
      @service_code="usps_priority_mail_express",
      @service_type="USPS Priority Mail Express",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=23.25,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="1-2",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=2,
      @error_messages=[],
      @estimated_delivery_date="2021-08-05T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="flat_rate_legal_envelope",
      @rate_id="se-795654966",
      @rate_type="shipment",
      @service_code="usps_priority_mail_express",
      @service_type="USPS Priority Mail Express",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=22.95,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="6",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=6,
      @error_messages=[],
      @estimated_delivery_date="2021-08-10T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="package",
      @rate_id="se-795654967",
      @rate_type="shipment",
      @service_code="usps_media_mail",
      @service_type="USPS Media Mail",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=2.89,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>,
     #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::RateResponse::Rate
      @carrier_code="stamps_com",
      @carrier_delivery_days="6",
      @carrier_friendly_name="Stamps.com",
      @carrier_id="se-423887",
      @carrier_nickname="ShipEngine Test Account - Stamps.com",
      @confirmation_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @delivery_days=6,
      @error_messages=[],
      @estimated_delivery_date="2021-08-10T00:00:00Z",
      @guaranteed_service=false,
      @insurance_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @negotiated_rate=false,
      @other_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=0.0,
        @currency="usd">,
      @package_type="package",
      @rate_id="se-795654968",
      @rate_type="shipment",
      @service_code="usps_parcel_select",
      @service_type="USPS Parcel Select Ground",
      @ship_date="2021-08-03T00:00:00Z",
      @shipping_amount=
       #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::MonetaryValue
        @amount=7.97,
        @currency="usd">,
      @tax_amount=nil,
      @trackable=true,
      @validation_status="valid",
      @warning_messages=[],
      @zone=7>],
   @shipment_id="se-144033517",
   @status="completed">,
 @return_to=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Address
   @address_line1="4009 Marathon Blvd",
   @address_line2="Suite 300",
   @address_line3=nil,
   @address_residential_indicator="unknown",
   @city_locality="Austin",
   @company_name="Example Corp.",
   @country_code="US",
   @name="John Doe",
   @phone="111-111-1111",
   @postal_code="78756",
   @state_province="TX">,
 @service_code=nil,
 @ship_date="2021-08-03T00:00:00Z",
 @ship_from=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Address
   @address_line1="4009 Marathon Blvd",
   @address_line2="Suite 300",
   @address_line3=nil,
   @address_residential_indicator="unknown",
   @city_locality="Austin",
   @company_name="Example Corp.",
   @country_code="US",
   @name="John Doe",
   @phone="111-111-1111",
   @postal_code="78756",
   @state_province="TX">,
 @ship_to=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Address
   @address_line1="525 S Winchester Blvd",
   @address_line2=nil,
   @address_line3=nil,
   @address_residential_indicator="yes",
   @city_locality="San Jose",
   @company_name=nil,
   @country_code="US",
   @name="Amanda Miller",
   @phone="555-555-5555",
   @postal_code="95128",
   @state_province="CA">,
 @shipment_id="se-144033517",
 @shipment_status="pending",
 @tags=[],
 @tax_identifiers=nil,
 @total_weight=
  #<ShipEngine::Domain::Rates::GetWithShipmentDetails::Response::Weight
   @unit="ounce",
   @value=1.0>,
 @warehouse_id=nil>

```