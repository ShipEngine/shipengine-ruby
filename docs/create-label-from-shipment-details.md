Create Label From Shipment Details
======================================
[ShipEngine](www.shipengine.com) allows you programmatically create shipping labels. Please see [our docs](https://www.shipengine.com/docs/labels/create-a-label/) to learn more about creating shipping labels.

Input Parameters
-------------------------------------

The `create_label_from_shipment_details` method accepts shipment related params detailed in the documentation above.

Output
--------------------------------
The `create_label_from_shipment_details` method returns the label that was created in a response class of ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response.

Example
```ruby
def create_label_from_shipment_details_demo_function()
	client = ShipEngine::Client.new("API-Key")

	shipment_details = {
	  shipment: {
	    service_code: "ups_ground",
	    ship_to: {
	      name: "Jane Doe",
	      address_line1: "525 S Winchester Blvd",
	      city_locality: "San Jose",
	      state_province: "CA",
	      postal_code: "95128",
	      country_code: "US",
	      address_residential_indicator: "yes"
	    },
	    ship_from: {
	      name: "John Doe",
	      company_name: "Example Corp",
	      phone: "555-555-5555",
	      address_line1: "4009 Marathon Blvd",
	      city_locality: "Austin",
	      state_province: "TX",
	      postal_code: "78756",
	      country_code: "US",
	      address_residential_indicator: "no"
	    },
	    packages: [
	      {
	        weight: {
	          value: 20,
	          unit: "ounce"
	        },
	        dimensions: {
	          height: 6,
	          width: 12,
	          length: 24,
	          unit: "inch"
	        }
	      }
	    ]
	  }
	}

	begin
	  result = client.create_label_from_shipment_details(shipment_details)
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

create_label_from_shipment_details_demo_function
```

Example Output
-----------------------------------------------------

### Successful Create Label Result
```ruby
#<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response
 @batch_id="",
 @carrier_code="ups",
 @carrier_id="se-423888",
 @charge_event="carrier_default",
 @created_at="2021-08-03T19:12:39.6561113Z",
 @display_scheme="label",
 @form_download=nil,
 @insurance_claim=nil,
 @insurance_cost=
  #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::MonetaryValue
   @amount=0.0,
   @currency="usd">,
 @is_international=false,
 @is_return_label=false,
 @label_download=
  #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::LabelDownload
   @href=
    "https://api.shipengine.com/v1/downloads/10/L6kH2O1G1ka_m5UHnxTBnQ/label-75290114.pdf",
   @pdf=
    "https://api.shipengine.com/v1/downloads/10/L6kH2O1G1ka_m5UHnxTBnQ/label-75290114.pdf",
   @png=
    "https://api.shipengine.com/v1/downloads/10/L6kH2O1G1ka_m5UHnxTBnQ/label-75290114.png",
   @zpl=
    "https://api.shipengine.com/v1/downloads/10/L6kH2O1G1ka_m5UHnxTBnQ/label-75290114.zpl">,
 @label_format="pdf",
 @label_id="se-75290114",
 @label_image_id=nil,
 @label_layout="4x6",
 @package_code="package",
 @packages=
  [#<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::Package
    @dimensions=
     #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::Dimensions
      @height=6.0,
      @length=24.0,
      @unit="inch",
      @width=12.0>,
    @external_package_id=nil,
    @insured_value=
     #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::MonetaryValue
      @amount=0.0,
      @currency="usd">,
    @label_messages=
     #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::Package::LabelMessages
      @reference1=nil,
      @reference2=nil,
      @reference3=nil>,
    @package_code="package",
    @tracking_number="1Z63R0960331651653",
    @weight=
     #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::Weight
      @unit="ounce",
      @value=20.0>>],
 @rma_number=nil,
 @service_code="ups_ground",
 @ship_date="2021-08-03T00:00:00Z",
 @shipment_cost=
  #<ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response::MonetaryValue
   @amount=27.98,
   @currency="usd">,
 @shipment_id="se-144018968",
 @status="completed",
 @trackable=true,
 @tracking_number="1Z63R0960331651653",
 @tracking_status="in_transit",
 @voided=false,
 @voided_at=nil>

```