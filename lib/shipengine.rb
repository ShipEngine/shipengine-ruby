# frozen_string_literal: true

# for client class
require 'shipengine/internal_client'
require 'shipengine/domain'

# just for exporting
require 'shipengine/version'
require 'shipengine/exceptions'

module ShipEngine
  class Client
    # make domain modules public
    def initialize(api_key:)
      internal_client = ShipEngine::InternalClient.new(api_key: api_key)
      @address = ShipEngine::Domain::Address.new(internal_client)
      @package = ShipEngine::Domain::Package.new(internal_client)
    end

    def validate_address(address)
      @address.validate(address)
    end

    def track_package_by_id(package_id)
      @package.track_by_id(package_id)
    end

    def track_package_by_tracking_number(number, carrier_code)
      @package.track_by_tracking_number(number, carrier_code)
    end
  end
end
