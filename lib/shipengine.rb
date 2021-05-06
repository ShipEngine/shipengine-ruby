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

    def initialize(api_key: nil, base_url: nil, retries: nil)
      @api_key = api_key
      @base_url = base_url || 'https://simengine.herokuapp.com/jsonrpc'
      @retries = retries || 0
      validate
    end

    def merge(api_key: nil, base_url: nil, retries: nil)
      copy = clone
      copy.api_key = api_key if api_key
      copy.base_url = base_url if base_url
      copy.retries =  retries if retries
      copy.validate
      copy
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    def validate
      Exceptions::FieldValueRequired.assert_field_exists('A ShipEngine API key', @api_key)
      Exceptions::FieldValueRequired.assert_field_exists('A Base URL', @base_url)
      Exceptions::FieldValueRequired.assert_field_exists('Retries', @retries)
    end
  end

  class Client
    attr_accessor :configuration

    def initialize(api_key:)
      @configuration = Configuration.new(api_key: api_key)

      internal_client = InternalClient.new(@configuration)
      @address = Domain::Address.new(internal_client)
      @package = Domain::Package.new(internal_client)
    end

    def validate_address(address, options = {})
      @address.validate(address, options)
    end

    def track_package_by_id(**args)
      @package.track_by_id(**args)
    end

    def track_package_by_tracking_number(**args)
      @package.track_by_tracking_number(**args)
    end
  end
end
