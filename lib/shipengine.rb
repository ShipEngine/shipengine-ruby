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
      internal_client = InternalClient.new(api_key: api_key)
      @address = Domain::Address.new(internal_client)
      @package = Domain::Package.new(internal_client)
    end

    def validate_address(**args)
      @address.validate(**args)
    end

    def track_package_by_id(**args)
      @package.track_by_id(**args)
    end

    def track_package_by_tracking_number(**args)
      @package.track_by_tracking_number(**args)
    end
  end
end
