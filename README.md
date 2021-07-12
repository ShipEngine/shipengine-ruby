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

Contributing
============

Install dependencies
--------------------
- You will need to `gem install bundler` before using the following command to install dependencies from the Gemfile.
```bash
bundle
```

Pre-Commit/Pre-Push Hooks
-------------------------
This project makes use of [Overcommit](https://github.com/sds/overcommit#usage) to enforce `pre-commit/push hooks`.
You will need to run `gem install overcommit` and then run the following:
```bash
overcommit --install
```
- From then on when you commit code `rake lint` will run, and when you push code `rake test` and `rake lint` will run.
Upon failure of either of these, you can run `rake fix` to auto-fix lint issues and format code, and re-commit/push.

Testing
-------
- While you are writing tests as you contribute code you can run tests ad-hoc via `rake` using the following command:
```bash
rake lint
```
**OR** you can `format code & auto-fix lint errors` with the following:
```bash
rake fix
```

- Lastly, you can run tests on change when you save changes to a given file with `guard`.
```bash
guard
```
> Note: `guard` also provides a repl after tests run for quick repl development.

Repl Development
----------------
- You can start a `pry` repl that already has `shipengine` required bun running the following command.
```bash
./bin/console
```
> If you prefer `irb` over `pry`, you can follow the instructions in the [./bin/console](./bin/console) file. Please
DO NOT commit any changes you make to that file, unless they are improvements to the console workflow.

