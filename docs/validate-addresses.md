Validate Addresses
================================
[ShipEngine](www.shipengine.com) allows you to validate an array of addresses before using it to create a shipment to ensure
accurate delivery of your packages. Please see [our docs](https://www.shipengine.com/docs/addresses/validation/) to learn more about validating addresses.

Input Parameters
------------------------------------
The `validate_addresses` method accepts an array of addresses as seen in the documentation above.

Output
--------------------------------
The `validate_addresses` method returns an array of address validation result objects in a response class of ShipEngine::Domain::Addresses::AddressValidation::Response

Example
```ruby
def validate_addresses_demo_function()
	client = ShipEngine::Client.new("API-Key")
	
	addresses_to_be_validated = [
	  {
	    name: "John Smith",
	    company_name: "ShipStation",
	    address_line1: "3800 N Lamar Blvd",
	    address_line2: "#220",
	    postal_code: '78756',
	    country_code: "US",
	    address_residential_indicator: 'no',
	  }, {
	    name: "John Smith",
	    company: "ShipMate",
	    city_locality: "Toronto",
	    state_province: "On",
	    postal_code: "M6K 3C3",
	    country_code: "CA",
	    address_line1: "123 Foo",
	  }
	]

	begin
	  result = client.validate_addresses(addresses_to_be_validated)
		puts Pry::ColorPrinter.pp(result)
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

validate_addresses_demo_function
```

Example Output
-----------------------------------------------------

### Array of validated addresses
```ruby
[#<ShipEngine::Domain::Addresses::AddressValidation::Response
  @matched_address=
   #<ShipEngine::Domain::Addresses::AddressValidation::Address
    @address_line1="3800 N LAMAR BLVD STE 220",
    @address_line2="",
    @address_line3=nil,
    @address_residential_indicator="no",
    @city_locality="AUSTIN",
    @company_name="SHIPSTATION",
    @country_code="US",
    @name="JOHN SMITH",
    @phone=nil,
    @postal_code="78756-0003",
    @state_province="TX">,
  @messages=[],
  @original_address=
   #<ShipEngine::Domain::Addresses::AddressValidation::Address
    @address_line1="3800 N Lamar Blvd",
    @address_line2="#220",
    @address_line3=nil,
    @address_residential_indicator="no",
    @city_locality=nil,
    @company_name="ShipStation",
    @country_code="US",
    @name="John Smith",
    @phone=nil,
    @postal_code="78756",
    @state_province=nil>,
  @status="verified">,
 #<ShipEngine::Domain::Addresses::AddressValidation::Response
  @matched_address=nil,
  @messages=
   [#<ShipEngine::Domain::Addresses::AddressValidation::Message
     @code="a1002",
     @message=
      "Could not match the inputted street name to a unique street name. No matches or too many matches were found.",
     @type="error">,
    #<ShipEngine::Domain::Addresses::AddressValidation::Message
     @code="a1004",
     @message=
      "This address has been partially verified down to the city level. This is NOT the highest level possible with the data provided.",
     @type="error">],
  @original_address=
   #<ShipEngine::Domain::Addresses::AddressValidation::Address
    @address_line1="123 Foo",
    @address_line2=nil,
    @address_line3=nil,
    @address_residential_indicator="unknown",
    @city_locality="Toronto",
    @company_name=nil,
    @country_code="CA",
    @name="John Smith",
    @phone=nil,
    @postal_code="M6K 3C3",
    @state_province="On">,
  @status="error">]
 ```