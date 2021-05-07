[![ShipEngine](https://shipengine.github.io/img/shipengine-logo-wide.png)](https://shipengine.com)

The Official Ruby SDK for ShipEngine

# Decisions

- `minitest` over `rspec` since minitest seems to be more much popular than rspec for OSS
- `rubocop`
- Supporting Ruby 2.6 (2.5 is no longer supported by Ruby as of March 2021).
- `faraday` for http since it's the most popular library, and it is used by Twilio.
- committing `Gemfile.lock` per the guidance here: https://github.com/rubygems/rubygems/issues/3372
- use hashes for objects rather than keyword arguments -- keyword arguments don't work well if you want to pass an optional option argument at the end, and their strongly typed nature can make validation less consistent (since you can still pass nil to them) (examples: https://developers.braintreepayments.com/reference/request/address/create/ruby, stripe: https://stripe.com/docs/api/idempotent_requests)
- a file containing a module with only class methods (class << self or self.foo) should have that module name, just like the class convention.

## Installation

- `bundle`

## Commands

- Run tests once: `rake test`
- Run tests on change: `guard`
- Lint: `rake lint`
- Autoformat: `rake fix`
