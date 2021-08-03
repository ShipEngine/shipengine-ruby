Void Label With Label Id
================================
[ShipEngine](www.shipengine.com) allows you to attempt to void a previously purchased label. Please see [our docs](https://www.shipengine.com/docs/labels/voiding/) to learn more about voiding a label.

Input Parameters
-------------------------------------
The `void_label_with_label_id` method accepts a string that contains the label Id that is being voided.

Output
--------------------------------
The `void_label_with_label_id` method returns an object that indicates the status of the void label request in a response class of ShipEngine::Domain::Labels::VoidLabel::Response.

Example
```ruby
def void_label_with_label_id_demo_function()
	client = ShipEngine::Client.new("API-Key")
	begin
	  result = client.void_label_with_label_id('se-451990109')
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

void_label_with_label_id_demo_function
```

Example Output
-----------------------------------------------------

### Successful Void Label Result
```ruby
#<ShipEngine::Domain::Labels::VoidLabel::Response
 @approved=false,
 @message="Request for refund submitted.  This label has been voided.">

```