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
    def initialize(api_key:, base_url: nil, retries: nil)
      @api_key = api_key
      @base_url = base_url || 'https://simengine.herokuapp.com/jsonrpc'
      @retries = retries || 0
      validate()
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    def validate()
       Exceptions::FieldValueRequired.assert_field_exists('A ShipEngine API key', @api_key)
       Exceptions::FieldValueRequired.assert_field_exists('A Base URL', @base_url)
       Exceptions::FieldValueRequired.assert_field_exists('Retries', @retries)
    end

  end


  class Client
    attr_accessor :configuration
    def initialize(api_key:)
      @configuration = Configuration.new(api_key: api_key)
    end

    def validate_address(**args)
      @address = Domain::Address.new(InternalClient.new(@configuration))
      @address.validate(**args)
    end

    def track_package_by_id(**args)
      @package = Domain::Package.new(InternalClient.new(@configuration))
      @package.track_by_id(**args)
    end

    def track_package_by_tracking_number(**args)
      @package = Domain::Package.new(InternalClient.new(@configuration))
      @package.track_by_tracking_number(**args)
    end
  end
end
