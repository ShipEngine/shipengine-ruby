List Carriers
======================================
[ShipEngine](www.shipengine.com) allows you to connect
your own carrier accounts through the ShipEngine [dashboard](https://www.shipengine.com/docs/carriers/setup/). You can list all the carrier accounts you have connected with the `list_carriers` method. To learn more about carrier accounts please see [our docs](https://www.shipengine.com/docs/reference/list-carriers/).

Output
--------------------------------
The `list_carriers` method returns an array of connected carrier accounts in a response class of ShipEngine::Domain::Carriers::ListCarriers::Response.

Example
```ruby
def list_carriers_demo_function()
	client = ShipEngine::Client.new("TEST_ycvJAgX6tLB1Awm9WGJmD8mpZ8wXiQ20WhqFowCk32s")
	begin
	  result = client.list_carriers
		puts result
	rescue ShipEngine::Exceptions::ShipEngineError => err
	  puts err
	end
end

list_carriers_demo_function
```

Example Output
-----------------------------------------------------

### Array of connected carrier accounts
```ruby
#<ShipEngine::Domain::Carriers::ListCarriers::Response
 @carriers=
  [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier
    @account_number="test_account_423887",
    @balance=8210.1,
    @carrier_code="stamps_com",
    @carrier_id="se-423887",
    @friendly_name="Stamps.com",
    @has_multi_package_supporting_services=false,
    @nickname="ShipEngine Test Account - Stamps.com",
    @options=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="non_machinable">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value=nil,
       @description="Bill To Account",
       @name="bill_to_account">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value=nil,
       @description="Bill To Party",
       @name="bill_to_party">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value=nil,
       @description="Bill To Postal Code",
       @name="bill_to_postal_code">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value=nil,
       @description="Bill To Country Code",
       @name="bill_to_country_code">],
    @packages=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Cubic",
       @dimensions=nil,
       @name="Cubic",
       @package_code="cubic",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "USPS flat rate envelope. A special cardboard envelope provided by the USPS that clearly indicates \"Flat Rate\".",
       @dimensions=nil,
       @name="Flat Rate Envelope",
       @package_code="flat_rate_envelope",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Flat Rate Legal Envelope",
       @dimensions=nil,
       @name="Flat Rate Legal Envelope",
       @package_code="flat_rate_legal_envelope",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Flat Rate Padded Envelope",
       @dimensions=nil,
       @name="Flat Rate Padded Envelope",
       @package_code="flat_rate_padded_envelope",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Large envelope or flat. Has one dimension that is between 11 1/2\" and 15\" long, 6 1/18\" and 12\" high, or 1/4\" and 3/4\" thick.",
       @dimensions=nil,
       @name="Large Envelope or Flat",
       @package_code="large_envelope_or_flat",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Large Flat Rate Box",
       @dimensions=nil,
       @name="Large Flat Rate Box",
       @package_code="large_flat_rate_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Large package. Longest side plus the distance around the thickest part is over 84\" and less than or equal to 108\".",
       @dimensions=nil,
       @name="Large Package (any side > 12\")",
       @package_code="large_package",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Letter",
       @dimensions=nil,
       @name="Letter",
       @package_code="letter",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "USPS flat rate box. A special 11\" x 8 1/2\" x 5 1/2\" or 14\" x 3.5\" x 12\" USPS box that clearly indicates \"Flat Rate Box\"",
       @dimensions=nil,
       @name="Medium Flat Rate Box",
       @package_code="medium_flat_rate_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Non-Rectangular package type that is cylindrical in shape.",
       @dimensions=nil,
       @name="Non Rectangular Package",
       @package_code="non_rectangular",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Package. Longest side plus the distance around the thickest part is less than or equal to 84\"",
       @dimensions=nil,
       @name="Package",
       @package_code="package",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Regional Rate Box A",
       @dimensions=nil,
       @name="Regional Rate Box A",
       @package_code="regional_rate_box_a",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Regional Rate Box B",
       @dimensions=nil,
       @name="Regional Rate Box B",
       @package_code="regional_rate_box_b",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Small Flat Rate Box",
       @dimensions=nil,
       @name="Small Flat Rate Box",
       @package_code="small_flat_rate_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Thick envelope. Envelopes or flats greater than 3/4\" at the thickest point.",
       @dimensions=nil,
       @name="Thick Envelope",
       @package_code="thick_envelope",
       @package_id=nil>],
    @primary=false,
    @requires_funded_amount=true,
    @services=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=false,
       @name="USPS First Class Mail",
       @service_code="usps_first_class_mail">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=false,
       @name="USPS Media Mail",
       @service_code="usps_media_mail">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=false,
       @name="USPS Parcel Select Ground",
       @service_code="usps_parcel_select">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=false,
       @name="USPS Priority Mail",
       @service_code="usps_priority_mail">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=false,
       @name="USPS Priority Mail Express",
       @service_code="usps_priority_mail_express">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=false,
       @name="USPS First Class Mail Intl",
       @service_code="usps_first_class_mail_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=false,
       @name="USPS Priority Mail Intl",
       @service_code="usps_priority_mail_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="stamps_com",
       @carrier_id="se-423887",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=false,
       @name="USPS Priority Mail Express Intl",
       @service_code="usps_priority_mail_express_international">],
    @supports_label_messages=true>,
   #<ShipEngine::Domain::Carriers::ListCarriers::Carrier
    @account_number="test_account_423888",
    @balance=0.0,
    @carrier_code="ups",
    @carrier_id="se-423888",
    @friendly_name="UPS",
    @has_multi_package_supporting_services=true,
    @nickname="ShipEngine Test Account - UPS",
    @options=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_account">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_country_code">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_party">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_postal_code">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="collect_on_delivery">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="contains_alcohol">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="delivered_duty_paid">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="dry_ice">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="0",
       @description="",
       @name="dry_ice_weight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="freight_class">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="non_machinable">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="saturday_delivery">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="Driver may release package without signature",
       @name="shipper_release">],
    @packages=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Package. Longest side plus the distance around the thickest part is less than or equal to 84\"",
       @dimensions=nil,
       @name="Package",
       @package_code="package",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Express Box - Large",
       @dimensions=nil,
       @name="UPS  Express® Box - Large",
       @package_code="ups__express_box_large",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="10 KG Box",
       @dimensions=nil,
       @name="UPS 10 KG Box®",
       @package_code="ups_10_kg_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="25 KG Box",
       @dimensions=nil,
       @name="UPS 25 KG Box®",
       @package_code="ups_25_kg_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Express Box",
       @dimensions=nil,
       @name="UPS Express® Box",
       @package_code="ups_express_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Express Box - Medium",
       @dimensions=nil,
       @name="UPS Express® Box - Medium",
       @package_code="ups_express_box_medium",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Express Box - Small",
       @dimensions=nil,
       @name="UPS Express® Box - Small",
       @package_code="ups_express_box_small",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Pak",
       @dimensions=nil,
       @name="UPS Express® Pak",
       @package_code="ups_express_pak",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Letter",
       @dimensions=nil,
       @name="UPS Letter",
       @package_code="ups_letter",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="Tube",
       @dimensions=nil,
       @name="UPS Tube",
       @package_code="ups_tube",
       @package_id=nil>],
    @primary=false,
    @requires_funded_amount=false,
    @services=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Standard®",
       @service_code="ups_standard_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS Next Day Air® Early",
       @service_code="ups_next_day_air_early_am">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Worldwide Express®",
       @service_code="ups_worldwide_express">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS Next Day Air®",
       @service_code="ups_next_day_air">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Ground® (International)",
       @service_code="ups_ground_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Worldwide Express Plus®",
       @service_code="ups_worldwide_express_plus">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS Next Day Air Saver®",
       @service_code="ups_next_day_air_saver">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Worldwide Expedited®",
       @service_code="ups_worldwide_expedited">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS 2nd Day Air AM®",
       @service_code="ups_2nd_day_air_am">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS 2nd Day Air®",
       @service_code="ups_2nd_day_air">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Worldwide Saver®",
       @service_code="ups_worldwide_saver">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS 2nd Day Air® (International)",
       @service_code="ups_2nd_day_air_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS 3 Day Select®",
       @service_code="ups_3_day_select">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="UPS® Ground",
       @service_code="ups_ground">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="ups",
       @carrier_id="se-423888",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="UPS Next Day Air® (International)",
       @service_code="ups_next_day_air_international">],
    @supports_label_messages=true>,
   #<ShipEngine::Domain::Carriers::ListCarriers::Carrier
    @account_number="test_account_423889",
    @balance=0.0,
    @carrier_code="fedex",
    @carrier_id="se-423889",
    @friendly_name="FedEx",
    @has_multi_package_supporting_services=true,
    @nickname="ShipEngine Test Account - FedEx",
    @options=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_account">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_country_code">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_party">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="bill_to_postal_code">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="",
       @description="",
       @name="collect_on_delivery">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="contains_alcohol">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="delivered_duty_paid">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="dry_ice">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="0",
       @description="",
       @name="dry_ice_weight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="non_machinable">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Option
       @default_value="false",
       @description="",
       @name="saturday_delivery">],
    @packages=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Envelope",
       @dimensions=nil,
       @name="FedEx One Rate® Envelope",
       @package_code="fedex_envelope_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Extra Large Box",
       @dimensions=nil,
       @name="FedEx One Rate® Extra Large Box",
       @package_code="fedex_extra_large_box_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Large Box",
       @dimensions=nil,
       @name="FedEx One Rate® Large Box",
       @package_code="fedex_large_box_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Medium Box",
       @dimensions=nil,
       @name="FedEx One Rate® Medium Box",
       @package_code="fedex_medium_box_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Pak",
       @dimensions=nil,
       @name="FedEx One Rate® Pak",
       @package_code="fedex_pak_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Small Box",
       @dimensions=nil,
       @name="FedEx One Rate® Small Box",
       @package_code="fedex_small_box_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Tube",
       @dimensions=nil,
       @name="FedEx One Rate® Tube",
       @package_code="fedex_tube_onerate",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® 10kg Box",
       @dimensions=nil,
       @name="FedEx® 10kg Box",
       @package_code="fedex_10kg_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® 25kg Box",
       @dimensions=nil,
       @name="FedEx® 25kg Box",
       @package_code="fedex_25kg_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Box",
       @dimensions=nil,
       @name="FedEx® Box",
       @package_code="fedex_box",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Envelope",
       @dimensions=nil,
       @name="FedEx® Envelope",
       @package_code="fedex_envelope",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Pak",
       @dimensions=nil,
       @name="FedEx® Pak",
       @package_code="fedex_pak",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description="FedEx® Tube",
       @dimensions=nil,
       @name="FedEx® Tube",
       @package_code="fedex_tube",
       @package_id=nil>,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Package
       @description=
        "Package. Longest side plus the distance around the thickest part is less than or equal to 84\"",
       @dimensions=nil,
       @name="Package",
       @package_code="package",
       @package_id=nil>],
    @primary=false,
    @requires_funded_amount=false,
    @services=
     [#<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx Ground®",
       @service_code="fedex_ground">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx Home Delivery®",
       @service_code="fedex_home_delivery">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx 2Day®",
       @service_code="fedex_2day">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx 2Day® A.M.",
       @service_code="fedex_2day_am">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx Express Saver®",
       @service_code="fedex_express_saver">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx Standard Overnight®",
       @service_code="fedex_standard_overnight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx Priority Overnight®",
       @service_code="fedex_priority_overnight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx First Overnight®",
       @service_code="fedex_first_overnight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx 1Day® Freight",
       @service_code="fedex_1_day_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx 2Day® Freight",
       @service_code="fedex_2_day_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx 3Day® Freight",
       @service_code="fedex_3_day_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=true,
       @international=false,
       @is_multi_package_supported=true,
       @name="FedEx First Overnight® Freight",
       @service_code="fedex_first_overnight_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International Ground®",
       @service_code="fedex_ground_international">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International Economy®",
       @service_code="fedex_international_economy">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International Priority®",
       @service_code="fedex_international_priority">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International First®",
       @service_code="fedex_international_first">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International Economy® Freight",
       @service_code="fedex_international_economy_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=true,
       @name="FedEx International Priority® Freight",
       @service_code="fedex_international_priority_freight">,
      #<ShipEngine::Domain::Carriers::ListCarriers::Carrier::Service
       @carrier_code="fedex",
       @carrier_id="se-423889",
       @domestic=false,
       @international=true,
       @is_multi_package_supported=false,
       @name="FedEx International Connect Plus®",
       @service_code="fedex_international_connect_plus">],
    @supports_label_messages=true>],
 @errors=[],
 @request_id="02f402ee-e0bb-46af-8fca-51d11c79ab66">
```
