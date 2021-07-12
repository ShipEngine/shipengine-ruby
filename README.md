[![ShipEngine](https://shipengine.github.io/img/shipengine-logo-wide.png)](https://shipengine.com)

ShipEngine Ruby SDK
===================

> :warning: **WARNING**: This is alpha software under active development and it is not ready for consumer use.

The Official Ruby SDK for [ShipEngine API](https://shipengine.com) offering low-level access as well as convenience methods.

Quick Start
===========

Install ShipEngine via [RubyGems](https://rubygems.org/)
```bash
gem install shipengine_sdk
```
- The only configuration requirement is an [API Key](https://www.shipengine.com/docs/auth/#api-keys).

Methods
-------
- [validate_address]() - Indicates whether the provided address is valid. If the
  address is valid, the method returns a normalized version of the address based on the standards of the country in
  which the address resides.
- [normalize_address]() - Returns a normalized, or standardized, version of the
  address. If the address cannot be normalized, an error is returned.
- [track_package_by_id]() - Track a package by `packageId` (Ideal if you create a shipping label via ShipEngine).
- [track_package_by_tracking_number]() - Track a package by `carrierCode` and `trackingNumber`.


Class Objects
-------------
- [ShipEngine]() - A configurable entry point to the ShipEngine API SDK, this class provides convenience methods
  for various ShipEngine API Services.

Instantiate ShipEngine Class
----------------------------
```ruby
require "shipengine"

api_key = ENV["SHIPENGINE_API_KEY"]

shipengine = ShipEngine.new(api_key)
```

# Decisions

- `minitest` over `rspec` since minitest seems to be more much popular than rspec for OSS
- `rubocop-shopify` for good linting and sensible defaults
- Supporting Ruby 2.6 (2.5 is no longer supported by Ruby as of March 2021).
- `faraday` for http since it's the most popular library, and it is used by Twilio.
- committing `Gemfile.lock` per the guidance here: https://github.com/rubygems/rubygems/issues/3372
- use hashes for objects rather than keyword arguments -- keyword arguments don't work well if you want to pass an optional option argument at the end, and their strongly typed nature can make validation less consistent (since you can still pass nil to them) (examples: https://developers.braintreepayments.com/reference/request/address/create/ruby, stripe: https://stripe.com/docs/api/idempotent_requests)
- a file containing a module with only class methods (class << self or self.foo) should have that module name, just like the class convention.
- use Strings and not symbols for PUBLIC Ruby enums such as country code. None of the SDKs that I could [find](https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/Route53/Types/GeoLocation.html) uses Symbols. Since ruby does not have pattern matching, symbols do not provide the same benefit as strings, and come at a considerable ergonomic cost. Also, because they are not garbage-collected, there are "gotchas".

# Questions

- coercing empty strings from Address Validation to nil?

## Install dependencies
- You will need to `gem install bundler` before using the following command to install dependencies from the Gemfile.
```bash
bundle
```

Testing
-------


## Commands

- Run tests on change: `guard`
- Lint: `rake lint`
- Format / autofix lint errors: `rake fix`

## Repl Development

```bash
> guard
[1] guard(main)> require 'shipengine'
=> true
[2]> client = ShipEngine::Client.new("foo123")
#<ShipEngine::Client:0x00007f87d72d7d08
 @address=
  #<ShipEngine::Domain::Address:0x00007f87d72d7bf0
   @internal_client=
    #<ShipEngine::InternalClient:0x00007f87d72d7c18
     @configuration=
      #<ShipEngine::Configuration:0x00007f87d72d7c90
       @api_key="foo123",
       @base_url="https://foo.com/jsonrpc",
       @retries=0,
       @timeout=60>>>
       ....
[3]> client.track_package_by_id("pkg_foo123")
...
```
