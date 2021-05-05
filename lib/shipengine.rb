# frozen_string_literal: true

# for client class
require 'shipengine/internal_client'
require 'shipengine/domain'

# just for exporting
require 'shipengine/version'
require 'shipengine/exceptions'

module ShipEngine
  class Configuration
    attr_accessor :api_key, :retries, :base_url
    def initialize(api_key:, retries: nil)
      @api_key = api_key
      @retries = retries
      @base_url = 'https://simengine.herokuapp.com/jsonrpc'
    end
  end


  class Client
    attr_accessor :configuration
    def initialize(api_key:, retries: nil)
      @configuration = Configuration.new(api_key: api_key, retries: retries)
      internal_client = InternalClient.new(api_key: @configuration.api_key,  retries: @configuration.retries, base_url: @configuration.base_url)
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
