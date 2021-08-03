Track By Label ID
======================================
[ShipEngine](www.shipengine.com) allows you to track a package by its ShipEngine label ID. Please see [our docs](https://www.shipengine.com/docs/tracking/track-by-label-id/) to learn more about tracking shipments.

Input Parameters
-------------------------------------

The `track_using_label_id` method requires the ID of the label associated with the shipment you are trying to track.

Output
--------------------------------
The `track_using_label_id` method returns tracking information associated with the shipment for the given label ID in a response class of ShipEngine::Domain::Tracking::TrackUsingLabelId::Response.


Example
```ruby
def track_using_label_id_demo_function()
	client = ShipEngine::Client.new("API-Key")
	begin
	  result = client.track_using_label_id("se-73335564")
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

track_using_label_id_demo_function
```


Example Output
-----------------------------------------------------

### Tracking Result
```ruby
#<ShipEngine::Domain::Tracking::TrackUsingLabelId::Response
 @actual_delivery_date=nil,
 @carrier_status_code="-2147219284",
 @carrier_status_description=
  "A status update is not yet available for your package. It will be available when the shipper provides an update or the package is delivered to USPS. Check back soon. Sign up for Informed Delivery<SUP>&reg;</SUP> to receive notifications for packages addressed to you.",
 @estimated_delivery_date=nil,
 @events=[],
 @exception_description=nil,
 @shipped_date=nil,
 @status_code="NY",
 @status_description="Not Yet In System",
 @tracking_number="9461211899560335605036">

```