Create Label From Rate
======================================
[ShipEngine](www.shipengine.com) allows you programmatically create shipping labels. You can use the `create_label_from_rate` to create a shipping label from pre defined shipment information that is persisted in the `rate_id` that is passed to the function. Please see [our docs](https://www.shipengine.com/docs/labels/create-from-rate/) to learn more about creating shipping labels from a rate.

Input Parameters
-------------------------------------

The `create_label_from_rate` method requires a `rate_id` as well as some label details that are detailed in the documentation above.

Output
--------------------------------
The `create_label_from_rate` method returns the label that was created in a response class of ShipEngine::Domain::Labels::CreateFromRate::Response.

Example
```ruby
def create_label_from_rate_demo_function()
	client = ShipEngine::Client.new("API-Key")

	params = {
	  validate_address: "no_validation",
	  label_layout: "4x6",
	  label_format: "pdf",
	  label_download_type: "url",
	  display_scheme: "label"
	}

	begin
	  result = client.create_label_from_shipment_details('se-795684260', params)
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

create_label_from_rate_demo_function
```

Example Output
-----------------------------------------------------

### Successful Create Label From Rate Result
```ruby
#<ShipEngine::Domain::Labels::CreateFromRate::Response
 @batch_id="",
 @carrier_code="stamps_com",
 @carrier_id="se-423887",
 @charge_event="carrier_default",
 @created_at="2021-08-03T19:52:40.6378591Z",
 @display_scheme="label",
 @form_download=nil,
 @insurance_claim=nil,
 @insurance_cost=
  #<ShipEngine::Domain::Labels::CreateFromRate::Response::MonetaryValue
   @amount=0.0,
   @currency="usd">,
 @is_international=false,
 @is_return_label=false,
 @label_download=
  #<ShipEngine::Domain::Labels::CreateFromRate::Response::LabelDownload
   @href=
    "https://api.shipengine.com/v1/downloads/10/nqQR0gqdkUmd_UWNiRy6Ew/label-75301494.pdf",
   @pdf=
    "https://api.shipengine.com/v1/downloads/10/nqQR0gqdkUmd_UWNiRy6Ew/label-75301494.pdf",
   @png=
    "https://api.shipengine.com/v1/downloads/10/nqQR0gqdkUmd_UWNiRy6Ew/label-75301494.png",
   @zpl=
    "https://api.shipengine.com/v1/downloads/10/nqQR0gqdkUmd_UWNiRy6Ew/label-75301494.zpl">,
 @label_format="pdf",
 @label_id="se-75301494",
 @label_image_id=nil,
 @label_layout="4x6",
 @package_code="package",
 @packages=
  [#<ShipEngine::Domain::Labels::CreateFromRate::Response::Package
    @dimensions=
     #<ShipEngine::Domain::Labels::CreateFromRate::Response::Dimensions
      @height=0.0,
      @length=0.0,
      @unit="inch",
      @width=0.0>,
    @external_package_id=nil,
    @insured_value=
     #<ShipEngine::Domain::Labels::CreateFromRate::Response::MonetaryValue
      @amount=0.0,
      @currency="usd">,
    @label_messages=
     #<ShipEngine::Domain::Labels::CreateFromRate::Response::Package::LabelMessages
      @reference1=nil,
      @reference2=nil,
      @reference3=nil>,
    @package_code="package",
    @tracking_number="9400111899560334170636",
    @weight=
     #<ShipEngine::Domain::Labels::CreateFromRate::Response::Weight
      @unit="ounce",
      @value=1.0>>],
 @rma_number=nil,
 @service_code="usps_first_class_mail",
 @ship_date="2021-08-03T00:00:00Z",
 @shipment_cost=
  #<ShipEngine::Domain::Labels::CreateFromRate::Response::MonetaryValue
   @amount=3.35,
   @currency="usd">,
 @shipment_id="se-144039990",
 @status="completed",
 @trackable=true,
 @tracking_number="9400111899560334170636",
 @tracking_status="in_transit",
 @voided=false,
 @voided_at=nil>
```
