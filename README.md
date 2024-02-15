[![ShipEngine](https://shipengine.github.io/img/shipengine-logo-wide.png)](https://shipengine.com)

ShipEngine Ruby SDK
===================
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/ShipEngine/shipengine-ruby/CI?label=shipengine-ruby&logo=github)
![GitHub](https://img.shields.io/github/license/ShipEngine/shipengine-ruby?color=teal)

The Official Ruby SDK for [ShipEngine API](https://shipengine.com) offering low-level access as well as convenience methods.

Quick Start
===========

Install the ShipEngine SDK Gem via [RubyGems](https://rubygems.org/gems/shipengine_sdk)
```bash
gem install shipengine_sdk
```
- The only configuration requirement is an [API Key](https://www.shipengine.com/docs/auth/#api-keys).

Methods
-------
* [`create_label_from_rate`](./docs/create-label-from-rate.md) - When retrieving rates for shipments using the `get_rates` method, the returned information contains a `rate_id` property that can be used to purchase a label without having to refill in the shipment information repeatedly.
* [`create_label_from_shipment_details`](./docs/create-label-from-shipment-details.md) - Purchase and print a label for shipment.
* [`get_rates`](./docs/get-rates.md) - Given some shipment details and rate options, this method returns a list of rate quotes.
* [`list_carrier_accounts`](./docs/list-carrier-accounts.md) - Returns a list of carrier accounts that have been connected through
the [ShipEngine dashboard](https://www.shipengine.com/docs/carriers/setup/).
* [`track_by_label_id`](./docs/track-by-label-id.md) - Track a package by its associated label ID.
* [`track_using_carrier_code_and_tracking_number`](./docs/track-by-tracking-number.md) - Track a package by its associated trackng number.
* [`validate_addresses`](./docs/validate-addresses.md) - Indicates whether the provided addresses are valid. If the addresses are valid, the method returns a normalized version based on the standards of the country in which the address resides. If an address cannot be normalized, an error is returned.
* [`void_label_by_id`](./docs/void-label-by-id.md) - Void a label by its ID.

Class Objects
-------------
- [ShipEngine]() - A configurable entry point to the ShipEngine API SDK, this class provides convenience methods
  for various ShipEngine API Services.

Instantiate ShipEngine Class
----------------------------
```ruby
require "shipengine"

api_key = ENV["SHIPENGINE_API_KEY"]

shipengine = ShipEngine::Client.new(api_key)
```

Contributing
============

Install dependencies
--------------------
- You will need to `gem install bundler` before using the following command to install dependencies from the Gemfile.
```bash
./bin/setup
```

Committing
-------------------------
This project adheres to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

Pre-Commit/Pre-Push Hooks
-------------------------
This project makes use of [Overcommit](https://github.com/sds/overcommit#usage) to enforce `pre-commit/push hooks`.
Overcommit will be downloaded and initialized as part of running the `./bin/setup` script, as outlined in the previous section.

- From then on when you commit code `rake lint` will run, and when you push code `rake test` and `rake lint` will run.
Upon failure of either of these, you can run `rake fix` to auto-fix lint issues and format code, and re-commit/push.

Testing & Development
---------------------
- While you are writing tests as you contribute code you can run tests ad-hoc via `rake` using the following command:
```bash
rake test
```
- You can run tests and have them re-run when you save changes to a given file with `guard`.
```bash
guard
```
Lastly, you can `format code & auto-fix lint errors` with the following:
```bash
rake fix
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

Publishing
-------------------------
Publishing new versions of the SDK to [RubyGems](https://rubygems.org/) is handled on GitHub via the [Release Please](https://github.com/googleapis/release-please) GitHub Actions workflow. Learn more about about Release PRs, updating the changelog, and commit messages [here](https://github.com/googleapis/release-please#how-should-i-write-my-commits).
